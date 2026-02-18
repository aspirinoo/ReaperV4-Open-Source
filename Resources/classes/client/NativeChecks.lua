-- ReaperV4 Client Native Checks Class
-- Clean and optimized version

local class = class
local Logger = Logger
local GetConvar = GetConvar
local table = table
local json = json
local CreateThread = CreateThread
local type = type
local AddConvarChangeListener = AddConvarChangeListener
local Wait = Wait
local tostring = tostring
local tonumber = tonumber
local string = string

-- Native Rules Client class
local NativeRulesClientClass = class("NativeRulesClient")

-- RPC reference
local RPC = nil

-- Wait for RPC to be available
CreateThread(function()
    while _G.RPC == nil do
        Wait(20)
    end
    RPC = _G.RPC
end)

-- Constructor
function NativeRulesClientClass:constructor()
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
    
    self:build_natives()
    
    -- Listen for convar changes
    AddConvarChangeListener("reaper_native_rules", function()
        self:build_natives()
    end)
end

-- Build natives from convar
function NativeRulesClientClass:build_natives()
    self.rules = {}
    local rulesJson = GetConvar("reaper_native_rules", "{}")
    local rules = json.decode(rulesJson)
    
    for _, rule in pairs(rules) do
        if not self.rules[rule.native] then
            self.rules[rule.native] = {}
        end
        table.insert(self.rules[rule.native], rule)
    end
end

-- Get native rules
function NativeRulesClientClass:getNativeRules(native)
    return self.rules[native]
end

-- Get field value from object
function NativeRulesClientClass:getFieldValue(obj, fieldPath)
    for field in string.gmatch(fieldPath, "[^.]+") do
        if type(obj) ~= "table" then
            return nil
        end
        obj = obj[field]
    end
    return obj
end

-- Evaluate rule
function NativeRulesClientClass:evaluateRule(rule, args)
    if rule.type == "and" then
        for _, subRule in ipairs(rule.rules) do
            if not self:evaluateRule(subRule, args) then
                return false
            end
        end
        return true
    elseif rule.type == "or" then
        for _, subRule in ipairs(rule.rules) do
            if self:evaluateRule(subRule, args) then
                return true
            end
        end
        return false
    end
    
    local fieldValue = self:getFieldValue(args, rule.field)
    local operator = self.operators[rule.op]
    
    if not operator then
        error("Unknown operator: " .. tostring(rule.op))
    end
    
    return operator(fieldValue, rule.value)
end

-- Evaluate native
function NativeRulesClientClass:evaluateNative(native, args)
    local rules = self:getNativeRules(native)
    local hasRule = false
    local shouldContinue = false
    
    if rules then
        for _, rule in pairs(rules) do
            if self:evaluateRule(rule, args) then
                hasRule = true
                
                -- Wait for RPC if available
                while RPC == nil do
                    Wait(100)
                end
                
                local result = RPC:await("native_evaluation_failed", rule.id, args)
                if result.success then
                    shouldContinue = result.continue
                end
                break
            end
        end
    end
    
    return hasRule, shouldContinue
end

-- Create NativeRules instance
NativeRules = NativeRulesClientClass.new()

-- Cleanup thread
CreateThread(function()
    Wait(5000)
    _G.NativeRules = nil
end)