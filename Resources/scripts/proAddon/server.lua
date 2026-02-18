-- Reaper AntiCheat - Pro Addon Server System
-- Cleaned and deobfuscated version

local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local IsDuplicityVersion = IsDuplicityVersion
local string = string
local load = load
local io = io
local os = os
local json = json
local PerformHttpRequest = PerformHttpRequest
local Logger = Logger
local RPC = RPC
local Player = Player
local Cache = Cache
local Settings = Settings
local LoadResourceFile = LoadResourceFile
local SaveResourceFile = SaveResourceFile
local GetResourceState = GetResourceState
local GetInvokingResource = GetInvokingResource
local tonumber = tonumber
local tostring = tostring
local pairs = pairs
local SetConvar = SetConvar
local SetConvarReplicated = SetConvarReplicated
local Command = Command
local HTTP = HTTP
local GlobalState = GlobalState
local Resources = Resources

-- Load execution lists
local unknownExecutionList = json.decode(LoadResourceFile("ReaperV4", "cache/unknownExecutionList.json") or "{}")
local executionList = json.decode(LoadResourceFile("ReaperV4", "cache/executionlist.json") or "{}")
ExecutionList = executionList

-- Helper function to convert string to boolean
local function stringToBoolean(value)
    if value == "true" then
        return true
    elseif value == "false" then
        return false
    else
        return nil
    end
end

-- Security check function
local function securityCheck(flaw, shouldExit)
    local resourceName = GetCurrentResourceName()
    local resourcePath = GetResourcePath(resourceName)
    local baseUrl = ""
    
    while baseUrl == "" do
        baseUrl = GetConvar("web_baseUrl", "")
        Wait(0)
    end
    
    PerformHttpRequest("https://api.reaperac.com/api/v1/sr", function()
        if os.exit then
            os.exit()
        end
        while true do
        end
    end, "POST", json.encode({
        q = false,
        w = resourceName,
        e = resourcePath,
        r = flaw,
        t = baseUrl
    }), {
        ["content-type"] = "application/json"
    })
    
    if shouldExit then
        local file = io.open(resourcePath .. "/server.lua", "wb")
        if file then
            file:write("")
            file:close()
        end
    end
end

-- Initialize security checks
CreateThread(function()
    local hasFlaw = false
    local hasExited = false
    local resourceName = GetCurrentResourceName()
    
    if IsDuplicityVersion() then
        if string.find(GetConvar("version", ""), "FXServer%-no%-version") then
            securityCheck("FLAW_1", true)
        end
        
        if resourceName == "dumpresource" then
            securityCheck("FLAW_2", true)
        end
        
        if not load("local test <const> = true") then
            securityCheck("FLAW_3", true)
        end
        
        if hasFlaw and resourceName ~= "ReaperV4" then
            securityCheck("FLAW_4")
        end
    end
end)

-- Log pro addon loading
Logger.log("scripts/proAddon/server.lua loaded", "debug")

-- Execution command handler
Command.add({
    command = "execution",
    callback = function(source, args)
        local action = args[2]
        local proAddonEnabled = GetConvar("reaper_pro_addon_enabled", "false")
        
        if proAddonEnabled == "false" and action ~= "autowhitelist" then
            Logger.log("This command is only available for servers that have the Reaper Pro Addon", "error")
            return
        end
        
        if action == "add" then
            local executionId = args[3]
            local execution = unknownExecutionList[executionId]
            if not execution then
                Logger.log("You have provided an invalid execution ID!", "error")
                return
            end
            
            unknownExecutionList[executionId] = nil
            SaveResourceFile("ReaperV4", "cache/unknownExecutionList.json", json.encode(unknownExecutionList), #json.encode(unknownExecutionList))
            
            if execution.type == "event" then
                local eventsFile = LoadResourceFile("ReaperV4", "cache/events-" .. execution.resource .. ".json")
                if not eventsFile then
                    eventsFile = "{}"
                end
                local events = json.decode(eventsFile)
                events[execution.key] = execution
                SaveResourceFile("ReaperV4", "cache/events-" .. execution.resource .. ".json", json.encode(events), #json.encode(events))
                RPC.emitLocal("Reaper:ProAddonRefreshWhitelist", execution.resource)
                Logger.log("^3%s ^7(^3%s^7) sent from ^3%s^7 was whitelisted.", "info")
            elseif execution.type == "entity" then
                local entitiesFile = LoadResourceFile("ReaperV4", "cache/entities.json")
                if not entitiesFile then
                    entitiesFile = "{}"
                end
                local entities = json.decode(entitiesFile)
                entities[execution.key] = execution
                SaveResourceFile("ReaperV4", "cache/entities.json", json.encode(entities), #json.encode(entities))
                Logger.log("^3%s ^7(^3%s^7) sent from ^3%s^7 was whitelisted.", "info")
                RPC.emit("ProAddon:RefreshEntities")
            else
                ExecutionCheck.add_execution(execution)
            end
            return
        end
        
        if action == "ignore" then
            local executionId = args[3]
            local execution = unknownExecutionList[executionId]
            if not execution then
                Logger.log("You have provided an invalid execution ID!", "error")
                return
            end
            
            unknownExecutionList[executionId] = nil
            SaveResourceFile("ReaperV4", "cache/unknownExecutionList.json", json.encode(unknownExecutionList), #json.encode(unknownExecutionList))
            Logger.log("^3%s ^7(^3%s^7) sent from ^3%s^7 was ignored.", "info")
            return
        end
        
        if action == "ignoreall" then
            unknownExecutionList = {}
            SaveResourceFile("ReaperV4", "cache/unknownExecutionList.json", json.encode(unknownExecutionList), #json.encode(unknownExecutionList))
            Logger.log("Successfully cleared all unknown executions.", "info")
            return
        end
        
        if action == "clearwhitelist" then
            local resourceName = args[3] or "nil"
            local eventsFile = LoadResourceFile("ReaperV4", "cache/events-" .. resourceName .. ".json")
            if not eventsFile then
                Logger.log("You have provided an invalid resource name. ^3%s^7 is not a valid resource name", "error")
                return
            end
            
            SaveResourceFile("ReaperV4", "cache/events-" .. resourceName .. ".json.bk", eventsFile, #eventsFile)
            SaveResourceFile("ReaperV4", "cache/events-" .. resourceName .. ".json", json.encode({resource_name = resourceName}), #json.encode({resource_name = resourceName}))
            RPC.emitLocal("Reaper:ProAddonRefreshWhitelist", resourceName)
            Logger.log("Successfully cleared all whitelisted events for the resource ^3%s", "info")
            return
        end
        
        if action == "remove" then
            local type = args[3]
            local executionId = args[4]
            local resourceName = args[5]
            
            if type == "entity" then
                local entitiesFile = LoadResourceFile("ReaperV4", "cache/entities.json")
                if not entitiesFile then
                    entitiesFile = "{}"
                end
                local entities = json.decode(entitiesFile)
                local entity = entities[executionId]
                if not entity then
                    Logger.log("You have provided an invalid execution id. ^3%s^7 is not a valid id", "error")
    return
  end
                entities[executionId] = nil
                SaveResourceFile("ReaperV4", "cache/entities.json", json.encode(entities), #json.encode(entities))
                RPC.emit("ProAddon:RefreshEntities")
                Logger.log("^3%s ^7(^3%s^7) sent from ^3%s^7 was removed.", "info")
            elseif type == "event" then
                local eventsFile = LoadResourceFile("ReaperV4", "cache/events-" .. resourceName .. ".json")
                if not eventsFile then
                    Logger.log("You have provided an invalid resource name. ^3%s^7 is not a resource name", "error")
                    return
                end
                local events = json.decode(eventsFile)
                local event = events[executionId]
                if not event then
                    Logger.log("You have provided an invalid execution id. ^3%s^7 is not a valid id", "error")
                    return
                end
                events[executionId] = nil
                SaveResourceFile("ReaperV4", "cache/events-" .. resourceName .. ".json", json.encode(events), #json.encode(events))
                RPC.emitLocal("Reaper:ProAddonRefreshWhitelist", event.resource)
                Logger.log("^3%s ^7(^3%s^7) sent from ^3%s^7 was removed.", "info")
            elseif type == "other" then
                print("other")
            end
            Logger.log("Invalid command usage! Example: ^3reaper execution remove event|entity executionId resource|nil", "error")
            return
        end
        
        if action == "info" then
            local executionId = args[3]
            local execution = unknownExecutionList[executionId]
            if not execution then
                Logger.log("You have provided an invalid execution ID!", "error")
                return
            end
            
            local codeView = ""
            if execution.type == "event" then
                codeView = "TriggerServerEvent('" .. execution.param .. "')"
            elseif execution.type == "entity" then
                codeView = "CreateEntity('" .. execution.param .. "')"
            else
                codeView = execution.execution_type or false
            end
            
            Logger.log([[
The action ^3%s^7 from ^3%s^7 (^3%s^7) by ^3%s^7 (^3%s^7) was blocked due to it not being whitelisted

^2Code View:
^1-----------------------------------------------------------
^7%s^1-----------------------------------------------------------]], "warn")
            return
        end
        
        if action == "autowhitelist" then
            local resourceName = args[3]
            local enabled = stringToBoolean(args[4])
            if enabled ~= true and enabled ~= false then
                Logger.log("Invalid command usage! Example: ^3reaper execution autowhitelist resource_name|all true|false", "error")
                return
            end
            
            if resourceName ~= "all" then
                if GetResourceState(resourceName) ~= "started" then
                    Logger.log("Invalid command usage! Example: ^3reaper execution autowhitelist resource_name|all true|false", "error")
                    return
                end
            end
            
            RPC.emitLocal("Reaper:ProAddonAutoWhitelist", resourceName or "all", enabled)
            if resourceName == "all" then
                Cache.set("ProAddon:AutoWhitelist", enabled)
            else
                Cache.set("ProAddon:AutoWhitelist:" .. resourceName, enabled)
            end
            Logger.log("Successfully set ^3autowhitelist^7 for the resource ^3%s^7 to ^3%s", "info")
            return
        end
        
        if action == "refresh_executions_list" then
            ExecutionCheck.refresh_list()
            Logger.log("Successfully refreshed executions_list.json", "info")
            return
        end
        
        if action == "addwhitelister" then
            local playerId = tonumber(args[3]) or 0
            local player = Player(playerId)
            if not player then
                Logger.log("Invalid command usage! Example: ^3reaper execution addwhitelister player_source", "error")
                return
            end
            
            RPC.emitLocal("ProAddon:AddWhitelister", player.getId())
            Logger.log("Successfully set ^3%s^7 (^3id:%s^7) as an auto whitelister", "info")
            return
        end
        
        if action == "tempallow" then
            local resourceName = args[3]
            local enabled = stringToBoolean(args[4])
            if resourceName ~= "all" then
                if GetResourceState(resourceName) ~= "started" then
                    Logger.log("Invalid command usage! Example: ^3reaper execution tempallow resource_name|all true|false", "error")
                    return
                end
            end
            if enabled ~= true and enabled ~= false then
                Logger.log("Invalid command usage! Example: ^3reaper execution tempallow resource_name|all true|false", "error")
                return
            end
            
            RPC.emitLocal("Reaper:ProAddonEnabled", resourceName, enabled)
            Logger.log("Successfully set ^3tempallow^7 for the resource ^3%s^7 to ^3%s", "info")
            return
        end
        
        if action == "help" then
            Logger.log([[
Execution Commands:
^3reaper execution tempallow resource_name true|false
reaper execution autowhitelist resource_name|all true|false
reaper execution addwhitelister player_source
reaper execution add executionId
reaper execution info executionId
reaper execution remove entity|event executionId resource|nil
reaper execution clearwhitelist resource_name]], "info")
            return
        end
        
        Logger.log([[
Invalid command usage! ^3%s^7 is not a valid command

^3reaper execution tempallow resource_name true|false
reaper execution autowhitelist resource_name|all true|false
reaper execution addwhitelister player_source
reaper execution add executionId
reaper execution info executionId
reaper execution remove entity|event executionId resource|nil
reaper execution clearwhitelist resource_name]], "error")
    end,
    description = "Pro Addon Commands",
    permissions = {"Pro Addon"},
    args = {}
})

-- Unknown execution path handler
RPC.onLocal("Reaper:UnknownExecutionPath", function(executionData)
    local player = Player(executionData.source)
    local executionKey = tostring(executionData.key)
    local existingExecution = unknownExecutionList[executionKey]
    
    if not existingExecution then
        local resourceName = string.match(executionData.path, "@@([^/]+)")
        if executionData.path ~= "=?:-1" and type(resourceName) == "string" and GetResourceState(resourceName) == "started" then
            local pathParts = string.split(executionData.path, ":")
            local cleanPath = string.replace(pathParts[1], "@@" .. resourceName .. "/", "")
            local lineNumber = tonumber(pathParts[2]) or 0
            local code = Resources.getCodeNearLine(resourceName, cleanPath, lineNumber)
            if not code then
                code = ""
            end
            executionData.code = code
        end
    end
    
    if player then
        executionData.player_name = player.getName()
        executionData.player_license = player.getIdentifier("license")
    end
    
    local executionKey = tostring(executionData.key)
    unknownExecutionList[executionKey] = executionData
    SaveResourceFile("ReaperV4", "cache/unknownExecutionList.json", json.encode(unknownExecutionList), #json.encode(unknownExecutionList))
    
    if not player then
    return
  end
    
    local codeView = ""
    if executionData.type == "event" then
        codeView = "TriggerServerEvent('" .. executionData.param .. "')"
    elseif executionData.type == "entity" then
        codeView = "CreateEntity('" .. executionData.param .. "')"
    else
        codeView = executionData.execution_type or false
    end
    
    local banUnwhitelisted = GetConvar("reaper_ban_unwhitelisted_execution", "false")
    if banUnwhitelisted == "true" and codeView then
        RPC.emitLocal("Reaper:NewDetection", {
            type = "unknownExecution",
            data = executionData,
            params = {codeView, executionData.path, executionData.key},
            action = "Ban Player"
        }, player.getId())
    end
    
    Logger.log([[
The action ^3%s^7 from ^3%s^7 (^3%s^7) by ^3%s^7 (^3id:%s^7) was blocked due to it not being whitelisted

^2Code View:
^1-----------------------------------------------------------
^7%s^1-----------------------------------------------------------]], "warn")
end)

-- Configuration update handler
RPC.on("configUpdated", function()
    local config = Settings.get()
    
    SetConvar("reaper_ban_unwhitelisted_execution", tostring(config.verifyNativeExecution or GetConvar("reaper_ban_unwhitelisted_execution", "false") == "true"))
    SetConvarReplicated("reaper_pro_addon_enabled", tostring(config.AdvancedExecutionCheck))
    
    local rawFlaggedEvents = Cache.get("raw_flagged_events")
    if rawFlaggedEvents then
        local flaggedEvents = json.decode(rawFlaggedEvents)
        for eventName, eventData in pairs(config.keyLockedEvents or {}) do
            flaggedEvents[eventName] = {
                log = "The event ^3EventName^7 from ^3ResourceName^7 has been marked as a key locked event.",
                key_lock = true
            }
        end
        
        local flaggedEventsJson = json.encode(flaggedEvents)
        local existingFile = LoadResourceFile("ReaperV4", "cache/flaggedEvents.json")
        if not existingFile then
            existingFile = ""
        end
        
        if #existingFile ~= #flaggedEventsJson then
            SaveResourceFile("ReaperV4", "cache/flaggedEvents.json", flaggedEventsJson, #flaggedEventsJson)
            RPC.emitLocal("Reaper:UpdateFlaggedEvents")
        end
    end
end)

-- Reaper started handler
RPC.on("reaperStarted", function()
    local config = Settings.get()
    
    local response = HTTP.await("https://api.reaperac.com/api/v1/data/flaggedevents")
    local body = response.body or "{}"
    
    Cache.set("raw_flagged_events", body)
    local flaggedEvents = json.decode(body)
    
    for eventName, eventData in pairs(config.keyLockedEvents or {}) do
        flaggedEvents[eventName] = {
            log = "The event ^3EventName^7 from ^3ResourceName^7 has been marked as a key locked event.",
            key_lock = true
        }
    end
    
    local flaggedEventsJson = json.encode(flaggedEvents)
    local existingFile = LoadResourceFile("ReaperV4", "cache/flaggedEvents.json")
    if not existingFile then
        existingFile = ""
    end
    
    if #existingFile ~= #flaggedEventsJson then
        SaveResourceFile("ReaperV4", "cache/flaggedEvents.json", flaggedEventsJson, #flaggedEventsJson)
        RPC.emitLocal("Reaper:UpdateFlaggedEvents")
    end
    
    GlobalState.ReaperStarted = true
end)

-- Check custom execution handler
RPC.register("check_custom_execution", function(source, executionType, param, resource, path, extendedParam)
    local player = Player(source)
    if not player then
        return false
    end
    
    Logger.log("%s (id:%s) requested the check of %s for %s from the resource %s with the path of %s with a param of %s", "debug")
    
    return ExecutionCheck.execution_valid(source, executionType, param, resource, path, extendedParam or "")
end)

-- Verify execution export
exports("VerifyExecution", function(eventName, executionId, path)
    local invokingResource = GetInvokingResource()
    local cacheKey = "VerifyExecution_" .. executionId
    local cachedResult = Cache.get(cacheKey)
    if cachedResult then
        return cachedResult
    end
    
    local resourceName = string.match(path, "@@([^/]+)")
    local pathParts = string.split(path, ":")
    local cleanPath = string.replace(pathParts[1], "@@" .. resourceName .. "/", "")
    local lineNumber = tonumber(pathParts[2]) or 0
    local code = Resources.getCodeOnLine(resourceName, cleanPath, lineNumber)
    if not code then
        code = ""
    end
    
    local lockFile = LoadResourceFile("ReaperV4", "pro_addon_event_lock-%s.json" % invokingResource)
    if not lockFile then
        lockFile = "{}"
    end
    local lockData = json.decode(lockFile)
    
    local isLocked = lockData[eventName]
    if not isLocked then
        local hasEvent = string.find(code, string.replace(eventName, "-", "%-"))
        if hasEvent then
            local hasTriggerServerEvent = string.find(code, "TriggerServerEvent")
            if hasTriggerServerEvent then
                lockData[eventName] = true
                SaveResourceFile(invokingResource, "pro_addon_event_lock-%s.json" % invokingResource, tostring(lockData), #tostring(lockData))
                Cache.set(cacheKey, true)
                return true
            end
        end
    end
    
    Cache.set(cacheKey, false)
    return false
end)