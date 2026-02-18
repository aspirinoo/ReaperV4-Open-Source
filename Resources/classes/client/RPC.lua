-- ReaperV4 Client RPC Class
-- Clean and optimized version

local class = class
local Logger = Logger
local CreateThread = CreateThread
local TriggerServerEvent = TriggerServerEvent
local table_insert = table.insert
local GetGameTimer = GetGameTimer
local RegisterNetEvent = RegisterNetEvent
local RemoveEventHandler = RemoveEventHandler
local promise_new = promise.new
local math_random = math.random
local table_unpack = table.unpack
local msgpack_unpack = msgpack.unpack
local msgpack_pack_args = msgpack.pack_args
local warn = warn
local Wait = Wait
local Citizen = Citizen
local Citizen_Await = Citizen.Await
local string_len = string.len
local string_byte = string.byte

-- RPC class definition
local RPCClass = class("RPC")

-- Constructor
function RPCClass:constructor()
    self.registeredMethods = {}
    self.eventHandlers = {}
    self.pendingPromises = {}
    self.requestId = 0
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
        error(string.format("RPC method '%s' not found", methodName), 2)
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
    
    table.insert(self.eventHandlers[eventName], callback)
    
    RegisterNetEvent(eventName)
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
    
    TriggerServerEvent(eventName, ...)
end

-- Emit local event
function RPCClass:emitLocal(eventName, ...)
    if type(eventName) ~= "string" then
        error("Event name must be a string", 2)
    end
    
    TriggerEvent(eventName, ...)
end

-- Await RPC response
function RPCClass:await(methodName, ...)
    local requestId = self.requestId + 1
    self.requestId = requestId
    
    local promise = promise_new(function(resolve, reject)
        self.pendingPromises[requestId] = {
            resolve = resolve,
            reject = reject,
            timeout = GetGameTimer() + 30000 -- 30 second timeout
        }
    end)
    
    -- Send request to server
    TriggerServerEvent("Reaper:RPCRequest", methodName, requestId, ...)
    
    return promise
end

-- Handle RPC response
function RPCClass:handleResponse(requestId, success, result, error)
    local pendingPromise = self.pendingPromises[requestId]
    if not pendingPromise then
        return
    end
    
    self.pendingPromises[requestId] = nil
    
    if success then
        pendingPromise.resolve(result)
    else
        pendingPromise.reject(error)
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
            table.remove(self.eventHandlers[eventName], i)
            return true
    end
  end
    
    return false
end

-- Create RPC instance
RPC = RPCClass.new()

-- Cleanup thread
CreateThread(function()
    while true do
        RPC:cleanupExpiredPromises()
        Wait(5000)
    end
end)

-- Handle RPC responses
RegisterNetEvent("Reaper:RPCResponse")
AddEventHandler("Reaper:RPCResponse", function(requestId, success, result, error)
    RPC:handleResponse(requestId, success, result, error)
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

exports("EmitRPC", function(eventName, ...)
    return RPC:emit(eventName, ...)
end)

exports("AwaitRPC", function(methodName, ...)
    return RPC:await(methodName, ...)
end)
