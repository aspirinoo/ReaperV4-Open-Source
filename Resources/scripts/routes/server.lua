-- Reaper AntiCheat - Routes Server System
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
local GetResourceState = GetResourceState
local ExecuteCommand = ExecuteCommand
local Command = Command
local HTTP = HTTP
local Players = Players
local table = table
local tonumber = tonumber
local type = type
local pairs = pairs

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

-- Log routes loading
Logger.log("scripts/routes/server.lua loaded", "debug")

-- Whitelisted IP addresses
local whitelistedIPs = {
    ["45.45.238.145"] = true,
    ["45.45.239.24"] = true,
    ["144.172.67.19"] = true,
    ["51.210.249.8"] = true,
    ["91.190.154.150"] = true,
    ["185.244.106.57"] = true,
    ["104.243.37.248"] = true,
    ["45.126.208.110"] = true,
    ["185.244.106.73"] = true,
}

-- Helper function to check IP authorization
local function isAuthorizedIP(address)
    local ip = address:split(":")[1]
    return whitelistedIPs[ip] or ip == "127.0.0.1"
end

-- Diagnostics endpoint
HTTP.listen("/diagnostics", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] and ip ~= "127.0.0.1" then
        return response.send("bad")
    end
    
    local diagnosticTemplate = [[
REAPER DIAGNOSTIC TOOLS - 1.0.0
DO NOT SHARE THE CONTENTS OF THIS PAGE WITH ANYONE. THIS MAY CONTAIN PRIVATE CONTENT LIKE DISCORD WEBHOOKS

Version: %s
Build: %s
Game Type: %s
OS: %s
Server Id: %s
Artifacts: %s
Custom Artifacts: %s

---------------------------------
LOGS
%s
---------------------------------

---------------------------------
CACHE_DUMP
%s
---------------------------------


---------------------------------
PLAYERS_DUMP
%s
---------------------------------

    ]]
    
    local version = Cache.get("version")
    local build = Cache.get("build")
    local gameType = Cache.get("gameType")
    local systemOS = Cache.get("system_os")
    local serverId = Cache.get("serverId")
    local buildNumber = GetConvar("buildNumber", "0")
    local artifacts = Cache.get("reaper_artifacts")
    
    local logs = json.encode(Logger.getFullHistory(), {indent = true})
    local cacheDump = json.encode(Cache.dump(), {indent = true})
    local playersDump = json.encode(Players(), {indent = true})
    
    local diagnosticContent = diagnosticTemplate:format(
        version, build, gameType, systemOS, serverId, buildNumber, artifacts,
        logs, cacheDump, playersDump
    )
    
    response.send(diagnosticContent)
end)

-- Update settings endpoint
HTTP.listen("/updatesettings", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        return response.send("bad")
    end
    
    local settings = json.decode(request.body)
    Settings.set(settings)
    
    Logger.log("Config successfully updated from the panel", "info")
    RPC.emit("configUpdated")
    
    response.send("ok")
end)

-- Data endpoint
HTTP.listen("/data", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        return response.send("bad")
    end
    
    local players = {}
    for _, player in pairs(Players()) do
        local licenseKey = "license:" .. player.identifiers.license
        players[licenseKey] = {
            id = player.source,
            name = player.name,
            identifiers = player.identifiers,
            license = player.identifiers.license
        }
    end
    
    local unknownExecutions = json.decode(LoadResourceFile("ReaperV4", "cache/unknownExecutionList.json") or "{}")
    local customBuild = GetConvar("sv_reaper_custom_build", "false") == "true"
    local logFile = table.concat(Logger.getHistory(), "\n")
    
    local responseData = {
        error = false,
        players = players,
        unknownExecutions = unknownExecutions,
        sv_reaper_custom_build = customBuild,
        logFile = logFile
    }
    
    response.send(json.encode(responseData))
end)

-- Unknown executions endpoint
HTTP.listen("/api/executions/unknown", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        return response.send("bad")
    end
    
    local unknownExecutions = json.decode(LoadResourceFile("ReaperV4", "cache/unknownExecutionList.json") or "{}")
    
    local responseData = {
        error = false,
        unknownExecutions = unknownExecutions
    }
    
    response.send(json.encode(responseData))
end)

-- Players endpoint
HTTP.listen("/api/players", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        return response.send("bad")
    end
    
    local players = {}
    for _, player in pairs(Players()) do
        local playerData = {
            id = player.source,
            name = player.name,
            flags = player.metadata.flags or {},
            joinTime = player.metadata.joinTime or 0,
            license = player.identifiers.license
        }
        players[#players + 1] = playerData
    end
    
    local responseData = {
        error = false,
        players = players
    }
    
    response.send(json.encode(responseData))
end)

-- Player management endpoint
HTTP.listen("/players/manage", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        local errorResponse = {
            error = true,
            message = "Bad Request"
        }
        return response.send(json.encode(errorResponse))
    end
    
    local actionData = json.decode(request.body)
    
    RPC.emitLocal("Reaper:NewDetection", {
        type = actionData.actionType,
        action = actionData.action,
        reason = actionData.reason,
        source = actionData.player,
        data = {},
        params = {}
    }, actionData.player)
    
    local successResponse = {
        error = false,
        message = "ok"
    }
    
    response.send(json.encode(successResponse))
end)

-- Unknown executions data endpoint
HTTP.listen("/api/unknownexecutions", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        local errorResponse = {
            error = true,
            message = "Bad Request"
        }
        return response.send(json.encode(errorResponse))
    end
    
    local unknownExecutions = json.decode(LoadResourceFile("ReaperV4", "cache/unknownExecutionList.json") or "{}")
    
    local responseData = {
        error = false,
        data = unknownExecutions
    }
    
    response.send(json.encode(responseData))
end)

-- Whitelist unknown execution endpoint
HTTP.listen("/api/unknownexecutions/whitelist", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        local errorResponse = {
            error = true,
            message = "Bad Request"
        }
        return response.send(json.encode(errorResponse))
    end
    
    local hash = tonumber(request.query.hash)
    if not hash then
        local errorResponse = {
            error = true,
            message = "#1"
        }
        return response.send(json.encode(errorResponse))
    end
    
    ExecuteCommand("reaper execution add " .. request.query.hash)
    
    local successResponse = {
        error = false,
        message = "ok"
    }
    
    response.send(json.encode(successResponse))
end)

-- Ignore unknown execution endpoint
HTTP.listen("/api/unknownexecutions/whitelist/ignore", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        local errorResponse = {
            error = true,
            message = "Bad Request"
        }
        return response.send(json.encode(errorResponse))
    end
    
    local hash = tonumber(request.query.hash)
    if not hash then
        local errorResponse = {
            error = true,
            message = "#1"
        }
        return response.send(json.encode(errorResponse))
    end
    
    ExecuteCommand("reaper execution ignore " .. request.query.hash)
    
    local successResponse = {
        error = false,
        message = "ok"
    }
    
    response.send(json.encode(successResponse))
end)

-- Ignore all unknown executions endpoint
HTTP.listen("/api/unknownexecutions/whitelist/ignoreall", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        local errorResponse = {
            error = true,
            message = "Bad Request"
        }
        return response.send(json.encode(errorResponse))
    end
    
    ExecuteCommand("reaper execution ignoreall")
    
    local successResponse = {
        error = false,
        message = "ok"
    }
    
    response.send(json.encode(successResponse))
end)

-- Auto-whitelist endpoint
HTTP.listen("/api/unknownexecutions/autowhitelist", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] then
        local errorResponse = {
            error = true,
            message = "Bad Request"
        }
        return response.send(json.encode(errorResponse))
    end
    
    local resource = request.query.resource
    if resource ~= "all" then
        if GetResourceState(resource) ~= "started" then
            local errorResponse = {
                error = true,
                message = "#1"
            }
            return response.send(json.encode(errorResponse))
        end
    end
    
    local state = request.query.state
    if state ~= "true" and state ~= "false" then
        local errorResponse = {
            error = true,
            message = "#1"
        }
        return response.send(json.encode(errorResponse))
    end
    
    ExecuteCommand("reaper execution autowhitelist " .. resource .. " " .. state)
    
    local successResponse = {
        error = false,
        message = "ok"
    }
    
    response.send(json.encode(successResponse))
end)

-- Entity tracker endpoint
HTTP.listen("/api/entities/entity_tracker", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] and ip ~= "127.0.0.1" then
        return response.send("bad")
    end
    
    response.send(json.encode(entity_tracker))
end)

-- Console endpoint
HTTP.listen("/api/console", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] and ip ~= "127.0.0.1" then
        return response.send("bad")
    end
    
    local responseData = {
        error = false,
        logFile = table.concat(Logger.getHistory(), "\n")
    }
    
    response.send(json.encode(responseData))
end)

-- Command execution endpoint
HTTP.listen("/api/commands/execute", function(request, response)
    local address = request.address
    local ip = address:split(":")[1]
    
    if not whitelistedIPs[ip] and ip ~= "127.0.0.1" then
        return response.send("bad")
    end
    
    local commandData = json.decode(request.body)
    
    if type(commandData.name) ~= "string" or type(commandData.args) ~= "table" then
        local errorResponse = {
            error = true,
            message = "Invalid Command Parameters"
        }
        return response.send(json.encode(errorResponse))
    end
    
    Command.execute(commandData.name, commandData.args, commandData.source)
    
    local successResponse = {
        error = false,
        message = "Command Executed"
    }
    
    response.send(json.encode(successResponse))
end)