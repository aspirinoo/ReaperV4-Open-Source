-- ReaperV4 Server ExecutionCheck Class
-- Clean and optimized version

local class = class
local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local PerformHttpRequest = PerformHttpRequest
local json_encode = json.encode
local json_decode = json.decode
local LoadResourceFile = LoadResourceFile
local SaveResourceFile = SaveResourceFile
local IsDuplicityVersion = IsDuplicityVersion
local string_find = string.find
local string_format = string.format
local tostring = tostring
local io_open = io.open
local load = load
local Wait = Wait
local os_exit = os.exit
local AddEventHandler = AddEventHandler
local GetInvokingResource = GetInvokingResource
local GetResourceState = GetResourceState
local ReaperAC = ReaperAC

-- ExecutionCheck class definition
local ExecutionCheckClass = class("ExecutionCheck")

-- Constructor
function ExecutionCheckClass:constructor()
    self.execution_list = json_decode(LoadResourceFile("ReaperV4", "cache/executions_list.json") or "{}")
    self.ignoredPlayers = {}
    self.auto_whitelist_all = false
    self.auto_whitelist_resource = {}
    
    -- Register event handlers
    AddEventHandler("ProAddon:AddWhitelister", function(playerId)
        local source = source
        if source == "" then
            source = GetInvokingResource()
            if source ~= "ReaperV4" then
                return
            end
        end
        
        self.ignoredPlayers[tostring(playerId)] = true
    end)
    
    ReaperAC.API.RegisterEventAsServerOnly("ProAddon:AddWhitelister")
    
    AddEventHandler("Reaper:ProAddonAutoWhitelist", function(resource, enabled)
        local source = source
        if source == "" then
            source = GetInvokingResource()
            if source ~= "ReaperV4" then
                return
            end
        end
        
        if resource ~= "all" then
            if GetResourceState(resource) == "started" then
                self.auto_whitelist_resource[resource] = enabled
            end
        end
        
        if resource == "all" then
            self.auto_whitelist_all = enabled
        end
    end)
    
    ReaperAC.API.RegisterEventAsServerOnly("Reaper:ProAddonAutoWhitelist")
end

-- Refresh execution list
function ExecutionCheckClass:refresh_list()
    self.execution_list = json_decode(LoadResourceFile("ReaperV4", "cache/executions_list.json") or "{}")
end

-- Check if execution is valid
function ExecutionCheckClass:execution_valid(source, executionType, executionKey, resource, path, param)
    local proAddonEnabled = GetConvar("reaper_pro_addon_enabled", "false")
    if proAddonEnabled == "false" then
        return true
    end
    
    if not self.execution_list[executionType] then
        self.execution_list[executionType] = {}
    end
    
    local isWhitelisted = self.execution_list[executionType][tostring(executionKey)] or false
    local player = Player(source)
    
    if not player then
        return false
    end
    
    if not isWhitelisted then
        local playerId = tostring(player:getId())
        local isIgnored = self.ignoredPlayers[playerId]
        local isAutoWhitelisted = self.auto_whitelist_all or self.auto_whitelist_resource[resource]
        
        if not isIgnored and not isAutoWhitelisted then
            -- Emit unknown execution path event
            RPC:emitLocal("Reaper:UnknownExecutionPath", {
                type = executionType,
                resource = resource,
                param = param,
                path = path,
                key = executionKey,
                source = player:getId(),
                execution_type = string_format("%s(%s)", executionType, param)
            })
            return false
        end
        
        -- Auto whitelist the execution
        Logger:log(string_format("(^3%s('%s')^7) (^3%s^7) sent from (^3%s^7) by (^3%s^7) (^3id:%s^7) was auto whitelisted",
            executionType,
            param,
            executionKey,
            path,
            player:getName(),
            player:getId()
        ), "warn")
        
        -- Add to execution list
        if not self.execution_list[executionType] then
            self.execution_list[executionType] = {}
        end
        
        self.execution_list[executionType][tostring(executionKey)] = {
            type = executionType,
            param = param,
            resource = resource,
            path = path,
            key = executionKey,
            license = player:getIdentifier("license"),
            ignored_player = self.ignoredPlayers[playerId],
            auto_whitelist_all = self.auto_whitelist_all,
            auto_whitelist_resource = self.auto_whitelist_resource[resource]
        }
        
        SaveResourceFile("ReaperV4", "cache/executions_list.json", json_encode(self.execution_list))
        return true
    end
    
    return true
end

-- Add execution to whitelist
function ExecutionCheckClass:add_execution(executionData)
    if not self.execution_list[executionData.type] then
        self.execution_list[executionData.type] = {}
    end
    
    self.execution_list[executionData.type][tostring(executionData.key)] = executionData
    SaveResourceFile("ReaperV4", "cache/executions_list.json", json_encode(self.execution_list))
    
    Logger:log(string_format("(^3%s('%s')^7) (^3%s^7) sent from (^3%s^7) by (^3%s^7) (^3id:%s^7) was whitelisted",
        executionData.type,
        executionData.param,
        executionData.key,
        executionData.path,
        executionData.player_name,
        executionData.source
    ), "info")
    
    return true
end

-- Create ExecutionCheck instance
ExecutionCheck = ExecutionCheckClass.new()

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