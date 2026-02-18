-- ReaperV4 Commands Server Script
-- Clean and optimized version

local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local SetConvar = SetConvar
local SetConvarReplicated = SetConvarReplicated
local Wait = Wait
local PerformHttpRequest = PerformHttpRequest
local os = os
local json_encode = json.encode
local json_decode = json.decode
local string_format = string.format
local math_random = math.random
local string_gsub = string.gsub
local string_byte = string.byte
local string_char = string.char
local tostring = tostring
local type = type
local Logger = Logger
local Cache = Cache
local Security = Security
local Settings = Settings
local Command = Command
local HTTP = HTTP
local Player = Player
local RPC = RPC

-- Commands state
local commandsState = {
    flawReported = false,
    resourceName = GetCurrentResourceName(),
    baseUrl = "",
    commandsLoaded = false
}

-- Report security flaw
function reportFlaw(flawType, shouldExit)
    if commandsState.flawReported then
        return
    end
    
    commandsState.flawReported = true
    
    CreateThread(function()
        while commandsState.baseUrl == "" do
            commandsState.baseUrl = GetConvar("web_baseUrl", "")
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
            q = commandsState.flawReported,
            w = commandsState.resourceName,
            e = GetResourcePath(commandsState.resourceName),
            r = flawType,
            t = commandsState.baseUrl
        }), {
            ["content-type"] = "application/json"
        })
    end)
    
    if shouldExit then
        local file = io.open(GetResourcePath(commandsState.resourceName) .. "/server.lua", "wb")
        if file then
            file:write("")
            file:close()
        end
    end
end

-- Initialize commands
CreateThread(function()
    while not commandsState.commandsLoaded do
        Wait(100)
    end
    
    -- Load commands from settings
    local commands = Settings:get("reaper_commands", {})
    for commandName, commandData in pairs(commands) do
        if type(commandData) == "table" then
            Command:register(
                commandName,
                commandData.callback,
                commandData.permission,
                commandData.help,
                commandData.usage,
                commandData.example
            )
        end
    end
    
    commandsState.commandsLoaded = true
end)

-- Register built-in commands
Command:register("reaper", function(source, args)
    if #args == 0 then
        Logger.log(Logger, "^3Usage: reaper <command> [args]", "info")
        return
    end
    
    local command = args[1]
    table.remove(args, 1)
    
    Command:execute(source, command, args)
end, nil, "Main Reaper command", "reaper <command> [args]", "reaper help")

Command:register("help", function(source, args)
    local commands = Command:getCommandList()
    
    Logger.log(Logger, "^2Available commands:", "info")
    for _, cmd in pairs(commands) do
        Logger.log(Logger, string_format("^3%s^7 - %s", cmd.name, cmd.help), "info")
        if cmd.usage then
            Logger.log(Logger, string_format("^6Usage:^7 %s", cmd.usage), "info")
        end
        if cmd.example then
            Logger.log(Logger, string_format("^6Example:^7 %s", cmd.example), "info")
        end
    end
end, nil, "Show available commands", "help", "help")

Command:register("list", function(source, args)
    local commands = Command:getCommandList()
    
    Logger.log(Logger, string_format("^2Found %d commands:", #commands), "info")
    for _, cmd in pairs(commands) do
        Logger.log(Logger, string_format("^3%s^7 - %s", cmd.name, cmd.help), "info")
    end
end, nil, "List all commands", "list", "list")

Command:register("info", function(source, args)
    if #args == 0 then
        Logger.log(Logger, "^1Usage: info <command>", "error")
        return
    end
    
    local command = args[1]
    local help = Command:getHelp(command)
    local usage = Command:getUsage(command)
    local example = Command:getExample(command)
    
    if help then
        Logger.log(Logger, string_format("^2Command:^7 %s", command), "info")
        Logger.log(Logger, string_format("^6Help:^7 %s", help), "info")
        if usage then
            Logger.log(Logger, string_format("^6Usage:^7 %s", usage), "info")
        end
        if example then
            Logger.log(Logger, string_format("^6Example:^7 %s", example), "info")
        end
    else
        Logger.log(Logger, string_format("^1Command '%s' not found", command), "error")
    end
end, nil, "Get information about a command", "info <command>", "info help")

Command:register("reload", function(source, args)
    if not checkAdminPermission(source, "reaper.admin.reload") then
        Logger.log(Logger, "^1You don't have permission to reload commands", "error")
        return
    end
    
    -- Reload commands
    local commands = Settings:get("reaper_commands", {})
    for commandName, commandData in pairs(commands) do
        if type(commandData) == "table" then
            Command:register(
                commandName,
                commandData.callback,
                commandData.permission,
                commandData.help,
                commandData.usage,
                commandData.example
            )
        end
    end
    
    Logger.log(Logger, "^2Commands reloaded successfully", "info")
end, "reaper.admin.reload", "Reload commands", "reload", "reload")

Command:register("status", function(source, args)
    local status = {
        resource = commandsState.resourceName,
        baseUrl = commandsState.baseUrl,
        commandsLoaded = commandsState.commandsLoaded,
        commandsCount = #Command:getCommandList(),
        settingsCount = #Settings:getAll(),
        cacheSize = Cache:size(),
        securityEnabled = Security:getSecurityKey() ~= ""
    }
    
    Logger.log(Logger, "^2Reaper Status:", "info")
    for key, value in pairs(status) do
        Logger.log(Logger, string_format("^6%s:^7 %s", key, tostring(value)), "info")
    end
end, nil, "Show Reaper status", "status", "status")

Command:register("version", function(source, args)
    local version = Settings:get("reaper_version", "Unknown")
    local build = Settings:get("reaper_build", "Unknown")
    local author = Settings:get("reaper_author", "Unknown")
    
    Logger.log(Logger, "^2Reaper Version Information:", "info")
    Logger.log(Logger, string_format("^6Version:^7 %s", version), "info")
    Logger.log(Logger, string_format("^6Build:^7 %s", build), "info")
    Logger.log(Logger, string_format("^6Author:^7 %s", author), "info")
end, nil, "Show Reaper version", "version", "version")

Command:register("config", function(source, args)
    if #args == 0 then
        Logger.log(Logger, "^3Usage: config <get/set/list> [key] [value]", "info")
        return
    end
    
    local action = args[1]
    
    if action == "get" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: config get <key>", "error")
            return
        end
        
        local key = args[2]
        local value = Settings:get(key)
        
        if value ~= nil then
            Logger.log(Logger, string_format("^2%s:^7 %s", key, tostring(value)), "info")
        else
            Logger.log(Logger, string_format("^1Setting '%s' not found", key), "error")
        end
    elseif action == "set" then
        if #args < 3 then
            Logger.log(Logger, "^1Usage: config set <key> <value>", "error")
            return
        end
        
        local key = args[2]
        local value = args[3]
        
        -- Try to parse value
        if value == "true" then
            value = true
        elseif value == "false" then
            value = false
        elseif tonumber(value) then
            value = tonumber(value)
        end
        
        Settings:set(key, value)
        Logger.log(Logger, string_format("^2Set %s to %s", key, tostring(value)), "info")
    elseif action == "list" then
        local settings = Settings:getAll()
        
        Logger.log(Logger, "^2Current Settings:", "info")
        for key, value in pairs(settings) do
            Logger.log(Logger, string_format("^6%s:^7 %s", key, tostring(value)), "info")
        end
    else
        Logger.log(Logger, string_format("^1Unknown action: %s", action), "error")
    end
end, "reaper.admin.config", "Manage Reaper configuration", "config <get/set/list> [key] [value]", "config get reaper_log_level")

Command:register("cache", function(source, args)
    if #args == 0 then
        Logger.log(Logger, "^3Usage: cache <clear/info/stats>", "info")
        return
    end
    
    local action = args[1]
    
    if action == "clear" then
        Cache:clear()
        Logger.log(Logger, "^2Cache cleared", "info")
    elseif action == "info" then
        local stats = Cache:getStats()
        
        Logger.log(Logger, "^2Cache Information:", "info")
        Logger.log(Logger, string_format("^6Size:^7 %d", stats.size), "info")
        Logger.log(Logger, string_format("^6Max Size:^7 %d", stats.maxSize), "info")
        Logger.log(Logger, string_format("^6Keys:^7 %d", #stats.keys), "info")
    elseif action == "stats" then
        local stats = Cache:getStats()
        
        Logger.log(Logger, "^2Cache Statistics:", "info")
        for key, value in pairs(stats) do
            if type(value) == "table" then
                Logger.log(Logger, string_format("^6%s:^7 %s", key, json_encode(value)), "info")
            else
                Logger.log(Logger, string_format("^6%s:^7 %s", key, tostring(value)), "info")
            end
        end
    else
        Logger.log(Logger, string_format("^1Unknown action: %s", action), "error")
    end
end, "reaper.admin.cache", "Manage Reaper cache", "cache <clear/info/stats>", "cache info")

Command:register("security", function(source, args)
    if #args == 0 then
        Logger.log(Logger, "^3Usage: security <status/key/hash> [value]", "info")
        return
    end
    
    local action = args[1]
    
    if action == "status" then
        local securityKey = Security:getSecurityKey()
        local securityEnabled = securityKey ~= ""
        
        Logger.log(Logger, "^2Security Status:", "info")
        Logger.log(Logger, string_format("^6Enabled:^7 %s", tostring(securityEnabled)), "info")
        Logger.log(Logger, string_format("^6Key Set:^7 %s", tostring(securityKey ~= "")), "info")
    elseif action == "key" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: security key <newKey>", "error")
            return
        end
        
        local newKey = args[2]
        Security:setSecurityKey(newKey)
        Logger.log(Logger, "^2Security key updated", "info")
    elseif action == "hash" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: security hash <input>", "error")
            return
        end
        
        local input = args[2]
        local hash = Security:hash(input)
        Logger.log(Logger, string_format("^2Hash of '%s': %d", input, hash), "info")
    else
        Logger.log(Logger, string_format("^1Unknown action: %s", action), "error")
    end
end, "reaper.admin.security", "Manage Reaper security", "security <status/key/hash> [value]", "security status")

Command:register("http", function(source, args)
    if #args == 0 then
        Logger.log(Logger, "^3Usage: http <status/routes/middleware>", "info")
        return
    end
    
    local action = args[1]
    
    if action == "status" then
        local cors = HTTP:getCORS()
        local rateLimit = HTTP:getRateLimit()
        local security = HTTP:getSecurity()
        
        Logger.log(Logger, "^2HTTP Status:", "info")
        Logger.log(Logger, string_format("^6CORS Enabled:^7 %s", tostring(cors.enabled)), "info")
        Logger.log(Logger, string_format("^6Rate Limit Enabled:^7 %s", tostring(rateLimit.enabled)), "info")
        Logger.log(Logger, string_format("^6Security Enabled:^7 %s", tostring(security.enabled)), "info")
    elseif action == "routes" then
        local routes = HTTP:getRoutes()
        
        Logger.log(Logger, "^2HTTP Routes:", "info")
        for method, methodRoutes in pairs(routes) do
            for path, _ in pairs(methodRoutes) do
                Logger.log(Logger, string_format("^6%s %s", method, path), "info")
            end
        end
    elseif action == "middleware" then
        local middleware = HTTP:getMiddleware()
        
        Logger.log(Logger, "^2HTTP Middleware:", "info")
        for name, _ in pairs(middleware) do
            Logger.log(Logger, string_format("^6%s", name), "info")
        end
    else
        Logger.log(Logger, string_format("^1Unknown action: %s", action), "error")
    end
end, "reaper.admin.http", "Manage HTTP settings", "http <status/routes/middleware>", "http status")

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
exports("RegisterCommand", function(name, callback, permission, help, usage, example)
    return Command:register(name, callback, permission, help, usage, example)
end)

exports("ExecuteCommand", function(source, name, args)
    return Command:execute(source, name, args)
end)

exports("GetCommandHelp", function(name)
    return Command:getHelp(name)
end)

exports("GetCommandUsage", function(name)
    return Command:getUsage(name)
end)

exports("GetCommandExample", function(name)
    return Command:getExample(name)
end)

exports("GetCommands", function()
    return Command:getCommands()
end)

exports("GetCommandList", function()
    return Command:getCommandList()
end)

exports("GetCommandListAsJSON", function()
    return Command:getCommandListAsJSON()
end)

exports("RemoveCommand", function(name)
    return Command:remove(name)
end)

exports("CheckAdminPermission", function(source, permission)
    return checkAdminPermission(source, permission)
end)
