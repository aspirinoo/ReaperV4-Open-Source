-- ReaperV4 Server EventKeyLock Class
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
local SetConvarReplicated = SetConvarReplicated
local IsDuplicityVersion = IsDuplicityVersion
local string_find = string.find
local string_format = string.format
local tostring = tostring
local io_open = io.open
local load = load
local Wait = Wait
local os_exit = os.exit

-- EventKeyLock class definition
local EventKeyLockClass = class("EventKeyLock")

-- Constructor
function EventKeyLockClass:constructor()
    self.event_lock_keys_client = json_decode(LoadResourceFile("ReaperV4", "cache/event_lock_client.json") or "{}")
    self.key_locked_events = {
        server = {},
        client = {}
    }
    
    -- Wait for RPC to be available
    while not RPC do
        Wait(0)
    end
    
    -- Register RPC callbacks
    RPC:on("configUpdated", function()
        self:refresh()
    end)
    
    RPC:register("key_lock:lock", function(source, eventName, executionKey, playerId, resource, path)
        local eventKeys = self:get_event_keys("client", eventName)
        if #eventKeys ~= 0 then
            return false
        end
        
        self:lock_event("client", eventName, executionKey, playerId, resource, path)
        return true
    end)
    
    RPC:register("key_lock:invalid_key", function(source, eventName, executionKey, resource, path)
        local player = Player(source)
        if not player then
            return false
        end
        
        player:NewLog(string_format("^3%s^7 (^3id:%s^7) just triggered the event (^3%s^7) with an invalid key (^3%s^7) from (^3%s^7) and was blocked. ^1An invalid key can be caused by a modification made to the script, an event being triggered from multiple places in a script, or from a cheat. If you know this key is legit, you can allow the key by running the following command. ^3reaper eventlockadd client %s %s^7",
            player:getName(),
            player:getId(),
            eventName,
            executionKey,
            string_format("%s:%s", resource, path),
            eventName,
            executionKey
        ), "info", "event_key_locks", {
            event = eventName,
            execution_key = executionKey,
            resource = resource,
            path = path
        })
        
        return true
    end)
    
    -- Register commands
    Command:add({
        command = "eventlockadd",
        callback = function(source, args)
            local origin = args[2]
            local eventName = args[3]
            local key = args[4]
            
            if origin == "client" then
                key = Security:hash(key)
            end
            
            if origin ~= "client" then
                Logger:log(string_format("You have provided an invalid origin. ^3%s^7 is not a valid origin", origin), "error")
                return
            end
            
            if not self.key_locked_events[origin][tostring(key)] then
                Logger:log(string_format("You have provided an invalid event. ^3%s^7 is not a valid event name", eventName), "error")
                return
            end
            
            if key and (#key == 19 or #key == 20 or #key == 18 or #key == 17) then
                self:lock_event(origin, eventName, key, 0)
            else
                Logger:log(string_format("You have provided an invalid event key lock. ^3%s^7 is not a valid key", key), "error")
            end
        end,
        args = {"origin", "event_name", "key"},
        permissions = {"Update Config"}
    })
    
    Command:add({
        command = "eventlockrefresh",
        callback = function(source, args)
            self:refresh()
            Logger:log("Successfully refreshed key locks.", "info")
        end,
        permissions = {"Update Config"}
    })
end

-- Refresh event key locks
function EventKeyLockClass:refresh()
    while not Security do
        Wait(0)
    end
    
    local settings = Settings:get()
    local keyLockedEvents = settings.keyLockedEvents or {}
    
    local response = HTTP:awaitSuccess("https://api.reaperac.com/api/v1/data/flaggedevents")
    local flaggedEvents = json_decode(response.body or "{}")
    
    local eventLocks = {
        client = {},
        server = {}
    }
    
    self.event_lock_keys_server = {}
    self.event_lock_keys_client = json_decode(LoadResourceFile("ReaperV4", "cache/event_lock_client.json") or "{}")
    
    -- Process flagged events
    for eventName, eventData in pairs(flaggedEvents) do
        local knownKeys = {}
        for key, _ in pairs(eventData.key_lock_known_keys or {}) do
            knownKeys[key] = true
        end
        
        if eventData.event_origin == "client" then
            local clientLocks = eventLocks.client
            local hashedEventName = tostring(Security:hash(eventName))
            
            if not clientLocks[hashedEventName] then
                clientLocks[hashedEventName] = {}
            end
            clientLocks[hashedEventName] = knownKeys
        end
    end
    
    -- Process key locked events
    for eventName, _ in pairs(keyLockedEvents) do
        local clientLocks = eventLocks.client
        local hashedEventName = tostring(Security:hash(eventName))
        
        if not clientLocks[hashedEventName] then
            clientLocks[hashedEventName] = {}
        end
        
        local serverLocks = eventLocks.server
        local eventNameStr = tostring(eventName)
        
        if not serverLocks[eventNameStr] then
            serverLocks[eventNameStr] = {}
        end
    end
    
    -- Process client event lock keys
    for eventName, eventKeys in pairs(self.event_lock_keys_client) do
        local clientLocks = eventLocks.client
        local hashedEventName = tostring(Security:hash(eventName))
        
        if not clientLocks[hashedEventName] then
            clientLocks[hashedEventName] = {}
        end
        
        for key, _ in pairs(eventKeys) do
            clientLocks[hashedEventName][key] = true
        end
    end
    
    -- Process server event lock keys
    for eventName, eventKeys in pairs(self.event_lock_keys_server) do
        local serverLocks = eventLocks.server
        local eventNameStr = tostring(eventName)
        
        if not serverLocks[eventNameStr] then
            serverLocks[eventNameStr] = {}
        end
        
        for key, _ in pairs(eventKeys) do
            serverLocks[eventNameStr][key] = true
        end
    end
    
    self.key_locked_events = eventLocks
    SetConvarReplicated("reaper_event_lock_client", json_encode(eventLocks.client))
end

-- Get event keys
function EventKeyLockClass:get_event_keys(origin, eventName)
    if origin == "server" then
        return {}
    elseif origin == "client" then
        return self.event_lock_keys_client[eventName] or {}
    end
    
    return {}
end

-- Lock event
function EventKeyLockClass:lock_event(origin, eventName, executionKey, playerId, resource, path)
    if origin == "server" then
        return false, "SERVER_ORIGIN_NOT_SUPPORTED"
    elseif origin == "client" then
        local clientLocks = self.key_locked_events.client
        local hashedEventName = tostring(Security:hash(eventName))
        
        if not clientLocks[hashedEventName] then
            return false, "INVALID_EVENT_NAME"
        end
        
        if not self.event_lock_keys_client[eventName] then
            self.event_lock_keys_client[eventName] = {}
        end
        
        local player = Player(playerId or 0)
        if player then
            self.event_lock_keys_client[eventName][executionKey] = {
                type = "auto",
                player = player:getIdentifier("license"),
                resource = resource,
                path = path
            }
        else
            self.event_lock_keys_client[eventName][executionKey] = {
                type = "manual"
            }
        end
        
        SaveResourceFile("ReaperV4", "cache/event_lock_client.json", json_encode(self.event_lock_keys_client))
        
        Logger:log(string_format("Successfully added ^3%s^7 as a key for the event ^3%s^7", executionKey, eventName), "info")
        
        self:refresh()
        return true, ""
    end
    
    return false, "INVALID_ORIGIN"
end

-- Add execution (placeholder)
function EventKeyLockClass:add_execution(executionData)
    -- Implementation for adding execution data
end

-- Create EventKeyLock instance
EventKeyLock = EventKeyLockClass.new()

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