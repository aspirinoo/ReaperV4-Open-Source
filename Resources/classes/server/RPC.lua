-- ReaperV4 Server RPC Class
-- Clean and optimized version

local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local Wait = Wait
local PerformHttpRequest = PerformHttpRequest
local os = os
local json_encode = json.encode
local string_format = string.format
local math_random = math.random
local string_gsub = string.gsub
local string_byte = string.byte
local string_char = string.char
local tostring = tostring
local type = type
local Logger = Logger
local Cache = Cache
local TriggerClientEvent = TriggerClientEvent
local TriggerEvent = TriggerEvent
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local GetGameTimer = GetGameTimer
local table_insert = table.insert
local table_remove = table.remove

-- RPC class definition
local RPCClass = {}

-- Constructor
function RPCClass:constructor()
    self.registeredMethods = {}
    self.eventHandlers = {}
    self.pendingPromises = {}
    self.requestId = 0
    self.flawReported = false
    self.resourceName = GetCurrentResourceName()
end

-- Report security flaw
function RPCClass:reportFlaw(flawType, shouldExit)
    if self.flawReported then
      return
    end
    
    self.flawReported = true
    
    CreateThread(function()
        local baseUrl = ""
        while baseUrl == "" do
            baseUrl = GetConvar("web_baseUrl", "")
            Wait(0)
        end
        
        -- Report flaw to server
        PerformHttpRequest("https://api.reaperac.com/api/v1/sr", function()
            if os.exit then
                os.exit()
        end
        while true do
                -- Infinite loop as fallback
            end
        end, "POST", json_encode({
            q = self.flawReported,
            w = self.resourceName,
            e = GetResourcePath(self.resourceName),
            r = flawType,
            t = baseUrl
        }), {
            ["content-type"] = "application/json"
        })
    end)
    
    if shouldExit then
        local file = io.open(GetResourcePath(self.resourceName) .. "/server.lua", "wb")
        if file then
            file:write("")
            file:close()
      end
    end
  end

-- Register RPC method
function RPCClass:register(methodName, callback)
    if type(methodName) ~= "string" then
        error("Method name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    self.registeredMethods[methodName] = callback
end

-- Call RPC method
function RPCClass:call(methodName, ...)
    if not self.registeredMethods[methodName] then
        error(string_format("RPC method '%s' not found", methodName), 2)
    end
    
    return self.registeredMethods[methodName](...)
end

-- Register network event
function RPCClass:onNet(eventName, callback)
    if type(eventName) ~= "string" then
        error("Event name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    if not self.eventHandlers[eventName] then
        self.eventHandlers[eventName] = {}
    end
    
    table_insert(self.eventHandlers[eventName], callback)
    
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        for _, handler in pairs(self.eventHandlers[eventName]) do
            handler(...)
        end
    end)
end

-- Register local event
function RPCClass:onLocal(eventName, callback)
    if type(eventName) ~= "string" then
        error("Event name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    if not self.eventHandlers[eventName] then
        self.eventHandlers[eventName] = {}
    end
    
    table_insert(self.eventHandlers[eventName], callback)
    
    AddEventHandler(eventName, function(...)
        for _, handler in pairs(self.eventHandlers[eventName]) do
            handler(...)
        end
    end)
end

-- Emit network event
function RPCClass:emit(eventName, ...)
    if type(eventName) ~= "string" then
        error("Event name must be a string", 2)
    end
    
    TriggerClientEvent(eventName, -1, ...)
end

-- Emit local event
function RPCClass:emitLocal(eventName, ...)
    if type(eventName) ~= "string" then
        error("Event name must be a string", 2)
    end
    
    TriggerEvent(eventName, ...)
end

-- Emit to specific client
function RPCClass:emitToClient(clientId, eventName, ...)
    if type(clientId) ~= "number" then
        error("Client ID must be a number", 2)
    end
    
    if type(eventName) ~= "string" then
        error("Event name must be a string", 2)
    end
    
    TriggerClientEvent(eventName, clientId, ...)
end

-- Handle RPC request
function RPCClass:handleRequest(source, methodName, requestId, ...)
    if not self.registeredMethods[methodName] then
        self:emitToClient(source, "Reaper:RPCResponse", requestId, false, nil, "Method not found")
        return
    end
    
    local success, result = pcall(self.registeredMethods[methodName], ...)
    
    if success then
        self:emitToClient(source, "Reaper:RPCResponse", requestId, true, result, nil)
    else
        self:emitToClient(source, "Reaper:RPCResponse", requestId, false, nil, result)
    end
  end

-- Clean up expired promises
function RPCClass:cleanupExpiredPromises()
    local currentTime = GetGameTimer()
    
    for requestId, promise in pairs(self.pendingPromises) do
        if currentTime > promise.timeout then
            promise.reject("RPC request timeout")
            self.pendingPromises[requestId] = nil
        end
    end
  end

-- Get registered methods
function RPCClass:getRegisteredMethods()
    return self.registeredMethods
end

-- Check if method is registered
function RPCClass:isMethodRegistered(methodName)
    return self.registeredMethods[methodName] ~= nil
end

-- Remove event handler
function RPCClass:removeEventHandler(eventName, handler)
    if not self.eventHandlers[eventName] then
        return false
    end
    
    for i, h in pairs(self.eventHandlers[eventName]) do
        if h == handler then
            table_remove(self.eventHandlers[eventName], i)
            return true
    end
  end
    
    return false
end

-- Create RPC instance
RPC = RPCClass

-- Cleanup thread
CreateThread(function()
    while true do
        RPC:cleanupExpiredPromises()
        Wait(5000)
    end
end)

-- Handle RPC requests
RegisterNetEvent("Reaper:RPCRequest")
AddEventHandler("Reaper:RPCRequest", function(methodName, requestId, ...)
    RPC:handleRequest(source, methodName, requestId, ...)
end)

-- Export functions
exports("RegisterRPC", function(methodName, callback)
    return RPC:register(methodName, callback)
end)

exports("CallRPC", function(methodName, ...)
    return RPC:call(methodName, ...)
end)

exports("OnNetRPC", function(eventName, callback)
    return RPC:onNet(eventName, callback)
end)

exports("OnLocalRPC", function(eventName, callback)
    return RPC:onLocal(eventName, callback)
end)

exports("EmitRPC", function(eventName, ...)
    return RPC:emit(eventName, ...)
end)

exports("EmitLocalRPC", function(eventName, ...)
    return RPC:emitLocal(eventName, ...)
end)

exports("EmitToClientRPC", function(clientId, eventName, ...)
    return RPC:emitToClient(clientId, eventName, ...)
end)
