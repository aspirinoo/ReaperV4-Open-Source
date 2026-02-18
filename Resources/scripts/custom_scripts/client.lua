-- ReaperV4 Custom Scripts Client
-- Clean and optimized version

local Logger = Logger
local RPC = RPC
local NUI = NUI
local Player = Player
local Security = Security
local Weapons = Weapons
local Math = Math
local String = String
local CreateThread = CreateThread
local Wait = Wait
local GetGameTimer = GetGameTimer
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords
local GetEntityHealth = GetEntityHealth
local GetPedArmour = GetPedArmour
local GetPlayerName = GetPlayerName
local GetPlayerIdentifiers = GetPlayerIdentifiers
local GetPlayerEndpoint = GetPlayerEndpoint
local GetPlayerPing = GetPlayerPing
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local TriggerServerEvent = TriggerServerEvent
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local type = type
local tostring = tostring
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_copy = table.copy
local json_encode = json.encode
local json_decode = json.decode
local os_time = os.time
local math_random = math.random

-- Custom scripts state
local customScriptsState = {
    scripts = {},
    loaded = false,
    lastUpdate = 0
}

-- Initialize custom scripts
CreateThread(function()
    while not customScriptsState.loaded do
        Wait(100)
    end
    
    -- Load custom scripts from settings
    local scripts = Settings:get("reaper_custom_scripts", {})
    for scriptName, scriptData in pairs(scripts) do
        if type(scriptData) == "table" then
            customScriptsState.scripts[scriptName] = scriptData
        end
    end
    
    customScriptsState.loaded = true
end)

-- Load custom script
function loadCustomScript(scriptName, scriptData)
    if type(scriptName) ~= "string" then
        error("Script name must be a string", 2)
    end
    
    if type(scriptData) ~= "table" then
        error("Script data must be a table", 2)
    end
    
    customScriptsState.scripts[scriptName] = scriptData
end

-- Unload custom script
function unloadCustomScript(scriptName)
    if type(scriptName) ~= "string" then
        error("Script name must be a string", 2)
    end
    
    customScriptsState.scripts[scriptName] = nil
end

-- Get custom script
function getCustomScript(scriptName)
    if type(scriptName) ~= "string" then
        error("Script name must be a string", 2)
    end
    
    return customScriptsState.scripts[scriptName]
end

-- Get all custom scripts
function getAllCustomScripts()
    return table_copy(customScriptsState.scripts)
end

-- Execute custom script
function executeCustomScript(scriptName, ...)
    if type(scriptName) ~= "string" then
        error("Script name must be a string", 2)
    end
    
    local script = customScriptsState.scripts[scriptName]
    if not script then
        error(string_format("Custom script '%s' not found", scriptName), 2)
    end
    
    if type(script.execute) == "function" then
        return script.execute(...)
    end
    
    return nil
end

-- Register custom script event
function registerCustomScriptEvent(eventName, callback)
    if type(eventName) ~= "string" then
        error("Event name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        callback(...)
    end)
end

-- Register custom script RPC
function registerCustomScriptRPC(methodName, callback)
    if type(methodName) ~= "string" then
        error("Method name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    RPC:register(methodName, callback)
end

-- Register custom script NUI callback
function registerCustomScriptNUICallback(callbackName, callback)
    if type(callbackName) ~= "string" then
        error("Callback name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    NUI:on(callbackName, function(data, cb)
        local result = callback(data, cb)
        return result
    end)
end

-- Send custom script NUI message
function sendCustomScriptNUIMessage(data)
    if type(data) ~= "table" then
        error("Data must be a table", 2)
    end
    
    NUI:sendMessage(data)
end

-- Get custom script data
function getCustomScriptData()
    return {
        scripts = customScriptsState.scripts,
        loaded = customScriptsState.loaded,
        lastUpdate = customScriptsState.lastUpdate
    }
end

-- Update custom script data
function updateCustomScriptData()
    customScriptsState.lastUpdate = GetGameTimer()
end

-- Check if custom script is loaded
function isCustomScriptLoaded(scriptName)
    if type(scriptName) ~= "string" then
        error("Script name must be a string", 2)
    end
    
    return customScriptsState.scripts[scriptName] ~= nil
end

-- Get custom script count
function getCustomScriptCount()
    local count = 0
    for _ in pairs(customScriptsState.scripts) do
        count = count + 1
    end
    return count
end

-- Clear all custom scripts
function clearAllCustomScripts()
    customScriptsState.scripts = {}
end

-- Reload custom scripts
function reloadCustomScripts()
    clearAllCustomScripts()
    
    -- Reload from settings
    local scripts = Settings:get("reaper_custom_scripts", {})
    for scriptName, scriptData in pairs(scripts) do
        if type(scriptData) == "table" then
            customScriptsState.scripts[scriptName] = scriptData
        end
    end
    
    updateCustomScriptData()
end

-- Export functions
exports("LoadCustomScript", function(scriptName, scriptData)
    return loadCustomScript(scriptName, scriptData)
end)

exports("UnloadCustomScript", function(scriptName)
    return unloadCustomScript(scriptName)
end)

exports("GetCustomScript", function(scriptName)
    return getCustomScript(scriptName)
end)

exports("GetAllCustomScripts", function()
    return getAllCustomScripts()
end)

exports("ExecuteCustomScript", function(scriptName, ...)
    return executeCustomScript(scriptName, ...)
end)

exports("RegisterCustomScriptEvent", function(eventName, callback)
    return registerCustomScriptEvent(eventName, callback)
end)

exports("RegisterCustomScriptRPC", function(methodName, callback)
    return registerCustomScriptRPC(methodName, callback)
end)

exports("RegisterCustomScriptNUICallback", function(callbackName, callback)
    return registerCustomScriptNUICallback(callbackName, callback)
end)

exports("SendCustomScriptNUIMessage", function(data)
    return sendCustomScriptNUIMessage(data)
end)

exports("GetCustomScriptData", function()
    return getCustomScriptData()
end)

exports("UpdateCustomScriptData", function()
    return updateCustomScriptData()
end)

exports("IsCustomScriptLoaded", function(scriptName)
    return isCustomScriptLoaded(scriptName)
end)

exports("GetCustomScriptCount", function()
    return getCustomScriptCount()
end)

exports("ClearAllCustomScripts", function()
    return clearAllCustomScripts()
end)

exports("ReloadCustomScripts", function()
    return reloadCustomScripts()
end)
