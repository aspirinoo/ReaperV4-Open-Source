-- ReaperV4 Function Hook Script
-- Clean and optimized version

local currentResource = GetCurrentResourceName()
if currentResource == "ReaperV4" then
    return
end

local msgpack = msgpack
local print = print
local Citizen = Citizen

-- Citizen pointer and result types
local PointerValueInt = Citizen.PointerValueInt()
local PointerValueFloat = Citizen.PointerValueFloat()
local PointerValueVector = Citizen.PointerValueVector()
local ReturnResultAnyway = Citizen.ReturnResultAnyway()
local ResultAsInteger = Citizen.ResultAsInteger()
local ResultAsFloat = Citizen.ResultAsFloat()
local ResultAsLong = Citizen.ResultAsLong()
local ResultAsString = Citizen.ResultAsString()
local ResultAsVector = Citizen.ResultAsVector()
local ResultAsObject = Citizen.ResultAsObject()

-- Function hook system
local functionHooks = {}
local hookedFunctions = {}

-- Register function hook
function RegisterFunctionHook(functionName, hookCallback)
    if type(functionName) ~= "string" then
        error("Function name must be a string", 2)
    end
    
    if type(hookCallback) ~= "function" then
        error("Hook callback must be a function", 2)
    end
    
    if not functionHooks[functionName] then
        functionHooks[functionName] = {}
    end
    
    table.insert(functionHooks[functionName], hookCallback)
end

-- Hook native function
function HookNativeFunction(nativeHash, hookCallback)
    if type(nativeHash) ~= "string" then
        error("Native hash must be a string", 2)
    end
    
    if type(hookCallback) ~= "function" then
        error("Hook callback must be a function", 2)
    end
    
    local originalNative = Citizen.GetNative(nativeHash)
    if not originalNative then
        return false
    end
    
    -- Store original native
    hookedFunctions[nativeHash] = originalNative
    
    -- Replace native with hooked version
    Citizen.SetNative(nativeHash, function(...)
        local args = {...}
        local shouldContinue, result = hookCallback(originalNative, table.unpack(args))
        
        if shouldContinue == false then
            return result
        end
        
        return originalNative(table.unpack(args))
    end)
    
    return true
end

-- Unhook native function
function UnhookNativeFunction(nativeHash)
    if type(nativeHash) ~= "string" then
        error("Native hash must be a string", 2)
    end
    
    local originalNative = hookedFunctions[nativeHash]
    if not originalNative then
        return false
    end
    
    Citizen.SetNative(nativeHash, originalNative)
    hookedFunctions[nativeHash] = nil
    
    return true
end

-- Get hooked function
function GetHookedFunction(nativeHash)
    if type(nativeHash) ~= "string" then
        error("Native hash must be a string", 2)
    end
    
    return hookedFunctions[nativeHash]
end

-- Check if function is hooked
function IsFunctionHooked(nativeHash)
    if type(nativeHash) ~= "string" then
        error("Native hash must be a string", 2)
    end
    
    return hookedFunctions[nativeHash] ~= nil
end

-- Get all hooked functions
function GetAllHookedFunctions()
    local hooked = {}
    for hash, _ in pairs(hookedFunctions) do
        table.insert(hooked, hash)
    end
    return hooked
end

-- Execute function hooks
function ExecuteFunctionHooks(functionName, ...)
    if type(functionName) ~= "string" then
        error("Function name must be a string", 2)
    end
    
    local hooks = functionHooks[functionName]
    if not hooks or #hooks == 0 then
        return true
    end
    
    local args = {...}
    for _, hook in ipairs(hooks) do
        local shouldContinue, result = hook(table.unpack(args))
        if shouldContinue == false then
            return false, result
        end
    end
    
    return true
end

-- Clear all function hooks
function ClearAllFunctionHooks()
    functionHooks = {}
end

-- Clear function hooks for specific function
function ClearFunctionHooks(functionName)
    if type(functionName) ~= "string" then
        error("Function name must be a string", 2)
    end
    
    functionHooks[functionName] = nil
end

-- Export functions
exports("RegisterFunctionHook", function(functionName, hookCallback)
    return RegisterFunctionHook(functionName, hookCallback)
end)

exports("HookNativeFunction", function(nativeHash, hookCallback)
    return HookNativeFunction(nativeHash, hookCallback)
end)

exports("UnhookNativeFunction", function(nativeHash)
    return UnhookNativeFunction(nativeHash)
end)

exports("GetHookedFunction", function(nativeHash)
    return GetHookedFunction(nativeHash)
end)

exports("IsFunctionHooked", function(nativeHash)
    return IsFunctionHooked(nativeHash)
end)

exports("GetAllHookedFunctions", function()
    return GetAllHookedFunctions()
end)

exports("ExecuteFunctionHooks", function(functionName, ...)
    return ExecuteFunctionHooks(functionName, ...)
end)

exports("ClearAllFunctionHooks", function()
    return ClearAllFunctionHooks()
end)

exports("ClearFunctionHooks", function(functionName)
    return ClearFunctionHooks(functionName)
end)
