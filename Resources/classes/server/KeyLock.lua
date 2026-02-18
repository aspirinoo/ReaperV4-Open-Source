-- ReaperV4 Server KeyLock Class
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
local IsDuplicityVersion = IsDuplicityVersion
local string_find = string.find
local tostring = tostring
local io_open = io.open
local load = load
local Wait = Wait
local os_exit = os.exit

-- KeyLock class definition
local KeyLockClass = class("KeyLock")

-- Constructor
function KeyLockClass:constructor()
    self.key_lock = json_decode(LoadResourceFile("ReaperV4", "cache/key_lock.json") or "{ server = {}, client = {} }")
    self.registered_key_locks = {}
    
    -- Wait for RPC to be available
    while not RPC do
        Wait(0)
    end
    
    -- Register RPC callbacks
    RPC:on("configUpdated", function()
        self:refresh()
    end)
    
    -- Register commands
    Command:add({
        command = "addkeylock",
        callback = function(source, args)
            -- Command implementation
        end,
        args = {"origin", "event_name", "key"},
        permissions = {"Update Config"}
    })
end

-- Get key lock ID
function KeyLockClass:getId(name, origin)
    return tostring(Security:hash(name .. origin .. "ReaperKeyLock"))
end

-- Get key lock
function KeyLockClass:get(name, origin)
    local id = self:getId(name, origin)
    return self.registered_key_locks[id]
end

-- Add key lock
function KeyLockClass:add(keyLockData)
    local id = self:getId(keyLockData.name, keyLockData.origin)
    
    self.registered_key_locks[id] = {
        name = keyLockData.name,
        origin = keyLockData.origin,
        description = keyLockData.description,
        message = keyLockData.message
    }
    
    return true
end

-- Verify key lock
function KeyLockClass:verify(id, source, args)
    local keyLock = self.registered_key_locks[id]
    if not keyLock then
        return error(string.format("^3%s^7 is not a valid key lock id", id))
    end
    
    print(json_encode(keyLock), source, args)
end

-- Refresh key locks
function KeyLockClass:refresh()
    -- Implementation for refreshing key locks
end

-- Create KeyLock instance
KeyLock = KeyLockClass.new()

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
exports("AddKeyLock", function(keyLockData)
    return KeyLock:add(keyLockData)
end)

exports("GetKeyLock", function(name, origin)
    return KeyLock:get(name, origin)
end)

exports("VerifyKeyLock", function(id, source, args)
    return KeyLock:verify(id, source, args)
end)