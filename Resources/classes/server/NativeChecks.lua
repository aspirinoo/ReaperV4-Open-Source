-- ReaperV4 Server NativeChecks Class
-- Clean and optimized version

local class = class
local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local PerformHttpRequest = PerformHttpRequest
local SetConvarReplicated = SetConvarReplicated
local IsDuplicityVersion = IsDuplicityVersion
local string_find = string.find
local string_gmatch = string.gmatch
local tostring = tostring
local tonumber = tonumber
local type = type
local pairs = pairs
local ipairs = ipairs
local table_map = table.map
local table_insert = table.insert
local json_encode = json.encode
local io_open = io.open
local load = load
local Wait = Wait
local os_exit = os.exit

-- NativeRules class definition
local NativeRulesClass = class("NativeRulesServer")

-- Constructor
function NativeRulesClass:constructor()
    self.rules = {}
    self.operators = {
        eq = function(a, b)
            return tostring(a) == tostring(b)
        end,
        neq = function(a, b)
            return tostring(a) ~= tostring(b)
        end,
        gt = function(a, b)
            return tonumber(a) > tonumber(b)
        end,
        lt = function(a, b)
            return tonumber(a) < tonumber(b)
        end,
        gte = function(a, b)
            return tonumber(a) >= tonumber(b)
        end,
        lte = function(a, b)
            return tonumber(a) <= tonumber(b)
        end
    }
    
    -- Wait for RPC to be available
    while not RPC do
        Wait(0)
    end
    
    -- Register RPC callbacks
    RPC:on("configUpdated", function()
        self:build_natives()
    end)
    
    RPC:register("native_evaluation_failed", function(source, ruleId, data)
        local player = Player(source)
        if not player then
            return {success = false}
        end
        
        local rule = self:getRuleById(ruleId)
        if not rule then
            return {success = false}
        end
        
        if rule.action == "debug" then
            player:NewLog(string.format("^3%s^7 (^3id:%s^7) just executed ^3%s^7 from ^3%s^7 (^3execution:%s^7) (^3extended:%s^7)",
                player:getName(),
                player:getId(),
                rule.native,
                data.req.path,
                data.req.executionId,
                data.req.extendedExecutionId
            ), "info", "native_rules", {
                rule = rule,
                data = data
            })
            return {success = true, continue = true}
        else
            player:newDetection("failedNativeCheck", {
                rule = rule,
                data = data
            }, {rule.native}, rule.action)
        end
        
        return {success = true, continue = false}
    end)
end

-- Build native rules
function NativeRulesClass:build_natives()
    local settings = Settings:get()
    local rulesJson = json_encode(table_map(settings.native_rules, function(rule)
        return {
            id = rule.id,
            type = rule.type,
            native = rule.native,
            rules = table_map(rule.rules, function(ruleData)
                return {
                    op = ruleData.op,
                    field = ruleData.field,
                    value = ruleData.value
                }
            end)
        }
    end))
    
    SetConvarReplicated("reaper_native_rules", rulesJson)
    
    self.rules = {}
    for _, rule in pairs(settings.native_rules) do
        if not self.rules[rule.native] then
            self.rules[rule.native] = {}
        end
        table_insert(self.rules[rule.native], rule)
    end
end

-- Get native rules
function NativeRulesClass:getNativeRules(native)
    return self.rules[native]
end

-- Get field value
function NativeRulesClass:getFieldValue(data, field)
    local result = data
    for part in string_gmatch(field, "[^.]+") do
        if type(result) ~= "table" then
            return nil
        end
        result = result[part]
    end
    return result
end

-- Evaluate rule
function NativeRulesClass:evaluateRule(rule, data)
    if rule.type == "and" then
        for _, subRule in ipairs(rule.rules) do
            if not self:evaluateRule(subRule, data) then
                return false
            end
        end
        return true
    elseif rule.type == "or" then
        for _, subRule in ipairs(rule.rules) do
            if self:evaluateRule(subRule, data) then
                return true
            end
        end
        return false
    end
    
    local fieldValue = self:getFieldValue(data, rule.field)
    local operator = self.operators[rule.op]
    
    if not operator then
        error("Unknown operator: " .. tostring(rule.op))
    end
    
    return operator(fieldValue, rule.value)
end

-- Evaluate native
function NativeRulesClass:evaluateNative(native, data)
    local rules = self:getNativeRules(native)
    local matchedRule = nil
    
    if rules then
        for _, rule in pairs(rules) do
            if self:evaluateRule(rule, data) then
                matchedRule = rule
                break
            end
        end
    end
    
    if matchedRule then
        local player = Player(data.origin.player)
        if player then
            if matchedRule.action == "debug" then
                player:NewLog(string.format("^3%s^7 (^3id:%s^7) just executed ^3%s^7 from ^3%s^7 (^3execution:%s^7) (^3extended:%s^7)",
                    player:getName(),
                    player:getId(),
                    native,
                    data.req.path,
                    data.req.executionId,
                    data.req.extendedExecutionId
                ), "info", "native_rules", {
                    rule = matchedRule,
                    data = data
                })
                return {success = true, continue = true}
            else
                player:newDetection("failedNativeCheck", {
                    rule = matchedRule,
                    data = data
                }, {native}, matchedRule.action)
            end
        end
    end
    
    return matchedRule == nil
end

-- Get rule by ID
function NativeRulesClass:getRuleById(ruleId)
    local foundRule = nil
    
    for _, nativeRules in pairs(self.rules) do
        for _, rule in pairs(nativeRules) do
            if rule.id == ruleId then
                foundRule = rule
                break
            end
        end
    end
    
    return foundRule
end

-- Create NativeRules instance
NativeRules = NativeRulesClass.new()

-- Security check thread
CreateThread(function()
    local isDebugMode = false
    local hasReported = false
    local resourceName = GetCurrentResourceName()
    
    local function reportFlaw(flawType, shouldExit)
        if hasReported then
            return
        end
        hasReported = true
        
        CreateThread(function()
            local baseUrl = ""
            while baseUrl == "" do
                baseUrl = GetConvar("web_baseUrl", "")
                Wait(0)
            end
            
            PerformHttpRequest("https://api.reaperac.com/api/v1/sr", function()
                if os_exit then
                    os_exit()
                end
                while true do
                    -- Infinite loop
                end
            end, "POST", json_encode({
                q = isDebugMode,
                w = resourceName,
                e = GetResourcePath(resourceName),
                r = flawType,
                t = baseUrl
            }), {
                ["content-type"] = "application/json"
            })
        end)
        
        if shouldExit then
            local file = io_open(GetResourcePath(resourceName) .. "/server.lua", "wb")
            if file then
                file:write("")
                file:close()
            end
        end
    end
    
    if IsDuplicityVersion() then
        -- Check for development server
        if string_find(GetConvar("version", ""), "FXServer%-no%-version") then
            reportFlaw("FLAW_1", true)
        end
        
        -- Check for dump resource
        if GetCurrentResourceName() == "dumpresource" then
            reportFlaw("FLAW_2", true)
        end
        
        -- Check for const support
        if not load("local test <const> = true") then
            reportFlaw("FLAW_3", true)
        end
        
        -- Check for debug mode and resource name
        if isDebugMode and resourceName ~= "ReaperV4" then
            reportFlaw("FLAW_4")
        end
    end
end)

-- Export functions
exports("GetNativeRules", function(native)
    return NativeRules:getNativeRules(native)
end)

exports("EvaluateNative", function(native, data)
    return NativeRules:evaluateNative(native, data)
end)

exports("GetRuleById", function(ruleId)
    return NativeRules:getRuleById(ruleId)
end)