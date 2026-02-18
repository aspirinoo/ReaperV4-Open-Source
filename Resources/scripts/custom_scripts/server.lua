-- ReaperV4 Custom Scripts Server
-- Clean and optimized version

local RPC = RPC
local Logger = Logger
local Player = Player
local Cache = Cache
local Security = Security
local Settings = Settings
local Command = Command
local HTTP = HTTP
local GetPlayers = GetPlayers
local GetPlayerName = GetPlayerName
local GetPlayerIdentifiers = GetPlayerIdentifiers
local GetPlayerEndpoint = GetPlayerEndpoint
local GetPlayerPing = GetPlayerPing
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local DropPlayer = DropPlayer
local TriggerClientEvent = TriggerClientEvent
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

-- Register custom script command
function registerCustomScriptCommand(commandName, callback, permission, help, usage, example)
    if type(commandName) ~= "string" then
        error("Command name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    Command:register(commandName, callback, permission, help, usage, example)
end

-- Register custom script HTTP route
function registerCustomScriptHTTPRoute(method, path, handler, middleware)
    if type(method) ~= "string" then
        error("Method must be a string", 2)
    end
    
    if type(path) ~= "string" then
        error("Path must be a string", 2)
    end
    
    if type(handler) ~= "function" then
        error("Handler must be a function", 2)
    end
    
    HTTP:addRoute(method, path, handler, middleware)
end

-- Register custom script HTTP middleware
function registerCustomScriptHTTPMiddleware(name, middleware)
    if type(name) ~= "string" then
        error("Middleware name must be a string", 2)
    end
    
    if type(middleware) ~= "function" then
        error("Middleware must be a function", 2)
    end
    
    HTTP:addMiddleware(name, middleware)
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
    customScriptsState.lastUpdate = os_time()
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

-- Register custom script events
RegisterNetEvent("Reaper:CustomScripts:GetData")
AddEventHandler("Reaper:CustomScripts:GetData", function()
    local source = source
    local data = getCustomScriptData()
    TriggerClientEvent("Reaper:CustomScripts:Data", source, data)
end)

RegisterNetEvent("Reaper:CustomScripts:Execute")
AddEventHandler("Reaper:CustomScripts:Execute", function(scriptName, ...)
    local source = source
    local result = executeCustomScript(scriptName, ...)
    TriggerClientEvent("Reaper:CustomScripts:Result", source, scriptName, result)
end)

RegisterNetEvent("Reaper:CustomScripts:Load")
AddEventHandler("Reaper:CustomScripts:Load", function(scriptName, scriptData)
    local source = source
    if not checkAdminPermission(source, "reaper.admin.custom_scripts") then
        return
    end
    
    loadCustomScript(scriptName, scriptData)
    TriggerClientEvent("Reaper:CustomScripts:Loaded", source, scriptName)
end)

RegisterNetEvent("Reaper:CustomScripts:Unload")
AddEventHandler("Reaper:CustomScripts:Unload", function(scriptName)
    local source = source
    if not checkAdminPermission(source, "reaper.admin.custom_scripts") then
        return
    end
    
    unloadCustomScript(scriptName)
    TriggerClientEvent("Reaper:CustomScripts:Unloaded", source, scriptName)
end)

RegisterNetEvent("Reaper:CustomScripts:Reload")
AddEventHandler("Reaper:CustomScripts:Reload", function()
    local source = source
    if not checkAdminPermission(source, "reaper.admin.custom_scripts") then
        return
    end
    
    reloadCustomScripts()
    TriggerClientEvent("Reaper:CustomScripts:Reloaded", source)
end)

-- Check admin permission helper
function checkAdminPermission(source, permission)
    if type(source) ~= "number" then
        return false
    end
    
    if type(permission) ~= "string" then
        return false
    end
    
    local player = Player(source)
    if not player then
        return false
    end
    
    return player:hasPermission(permission)
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

exports("RegisterCustomScriptCommand", function(commandName, callback, permission, help, usage, example)
    return registerCustomScriptCommand(commandName, callback, permission, help, usage, example)
end)

exports("RegisterCustomScriptHTTPRoute", function(method, path, handler, middleware)
    return registerCustomScriptHTTPRoute(method, path, handler, middleware)
end)

exports("RegisterCustomScriptHTTPMiddleware", function(name, middleware)
    return registerCustomScriptHTTPMiddleware(name, middleware)
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
