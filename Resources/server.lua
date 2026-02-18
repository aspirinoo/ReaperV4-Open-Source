-- ReaperV4 Server Script
-- Clean and optimized version

-- Import required modules
local Logger = require('classes.server.Logger')
local RPC = require('classes.server.RPC')
local Security = require('classes.server.Security')
local Cache = require('classes.server.Cache')
local Settings = require('classes.server.Settings')
local Resources = require('classes.server.Resources')
local Player = require('classes.server.Player')
local System = require('classes.server.System')
local HTTP = require('classes.server.HTTP')

-- Initialize logger
local log = Logger.log
log(Logger, "server.lua loaded", "debug")

-- Security checks
CreateThread(function()
    local hasFlaw = false
    local resourceName = GetCurrentResourceName()
    
    -- Security flaw detection function
    local function reportFlaw(flawType, shouldExit)
        if hasFlaw then
            return
        end
        hasFlaw = true
        
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
            end, "POST", json.encode({
                q = hasFlaw,
                w = resourceName,
                e = GetResourcePath(resourceName),
                r = flawType,
                t = baseUrl
            }), {
                ["content-type"] = "application/json"
            })
        end)
        
        if shouldExit then
            local file = io.open(GetResourcePath(resourceName) .. "/server.lua", "wb")
            if file then
                file:write("")
                file:close()
            end
        end
    end
    
    -- Check if running on server
    if IsDuplicityVersion() then
        -- Check for FXServer version flaw
        if string.find(GetConvar("version", ""), "FXServer%-no%-version") then
            reportFlaw("FLAW_1", true)
        end
        
        -- Check for resource name flaw
        if resourceName == "dumpresource" then
            reportFlaw("FLAW_2", true)
        end
        
        -- Check for Lua const support flaw
        if load("local test <const> = true") == nil then
            reportFlaw("FLAW_3", true)
        end
        
        -- Check for resource name mismatch
        if hasFlaw and resourceName ~= "ReaperV4" then
            reportFlaw("FLAW_4")
        end
    end
end)

-- Block connections until ready
ALLOW_CONNECTIONS = false

-- Check if this is the correct resource
if GetCurrentResourceName() ~= "ReaperV4" then
    return
end

-- Wait for initialization
Wait(800)

-- Version information
local versionInfo = {
    Version = "Premium - 4.3.8",
    Build = "0.0.6",
    DebugMode = false,
    DevBuild = false
}

-- Cache version information
Cache.set("version", versionInfo.Version)
Cache.set("build", versionInfo.Build)

log(Logger, "Loaded Reaper AntiCheat running version " .. versionInfo.Version, "info")
log(Logger, "Fetching server info from fivem.net, this may take a few minutes.", "info")

-- Get game type
local gameType = GetConvar("gamename", "gta5")
if gameType ~= "gta5" then
    print("REAPER ONLY SUPPORTS GTA5 AT THE MOMENT")
end

SetConvarReplicated("reaper_gameType", gameType)

-- Load server cache
local cacheData = LoadResourceFile("ReaperV4", "cache/cache.json")
while cacheData == nil do
    local baseUrl = System.getBaseUrl()
    local urlParts = baseUrl:split("-")
    local serverId = string.match(urlParts[#urlParts], "([^\"]+).users.cfx.re")
    
    local response = HTTP.await("https://servers-frontend.fivem.net/api/servers/single/" .. serverId)
    
    if response.status == 200 then
        local serverData = json.decode(response.body)
        local serverInfo = {
            serverId = serverId,
            ownerName = serverData.Data.ownerName,
            ownerID = serverData.Data.ownerID
        }
        
        local cacheContent = json.encode({
            key = Security.hash(json.encode(serverInfo)),
            data = json.encode(serverInfo)
        })
        
        cacheData = cacheContent
        SaveResourceFile("ReaperV4", "cache/cache.json", cacheContent, cacheContent:len())
        break
    else
        Wait(10000)
        log(Logger, string.format("Fetching server info from fivem.net returned a status code of %s. This may take some time", response.status), "warn")
    end
end

-- Parse cache data
local cacheJson = json.decode(cacheData)
local serverInfo = json.decode(cacheJson.data)

-- Verify server ID
CreateThread(function()
    local baseUrl = System.getBaseUrl()
    local urlParts = baseUrl:split("-")
    local currentServerId = string.match(urlParts[#urlParts], "([^\"]+).users.cfx.re")
    
    if serverInfo.serverId ~= currentServerId then
        log(Logger, "Please delete the cache.json file in ReaperV4/cache and restart the server", "error")
        log(Logger, "Please delete the cache.json file in ReaperV4/cache and restart the server", "error")
        log(Logger, "Please delete the cache.json file in ReaperV4/cache and restart the server", "error")
        log(Logger, "Please delete the cache.json file in ReaperV4/cache and restart the server", "error")
        os.exit("Please delete the cache.json file in ReaperV4/cache and restart the server")
    end
end)

log(Logger, "Authenticating with reaperac.com", "info")

-- Generate security key
local securityKey = GetConvar("reaperSecurityKey", Security.genUUID())

-- Authenticate with Reaper API
local authResponse = HTTP.await("https://api.reaperac.com/api/v1/servers/auth", "POST", json.encode({
    serverId = serverInfo.serverId,
    ownerName = serverInfo.ownerName,
    ownerId = serverInfo.ownerID,
    version = versionInfo.Version,
    build = versionInfo.Build,
    resources = Resources.getData(),
    tbxId = LoadResourceFile("ReaperV4", "key.tebex"),
    sv_projectName = GetConvar("sv_projectName", "My FXServer Project"),
    gameType = gameType,
    locale = GetConvar("locale", "en-US"),
    os = System.getOs(),
    sv_icon = GetConvar("sv_icon", ""),
    buildNumber = GetConvar("buildNumber", ""),
    onesync = GetConvar("onesync", "unknown"),
    security_key = securityKey,
    custom_artifacts = GetConvar("sv_reaper_custom_build", "false") == "true"
}), {
    ["Content-Type"] = "application/json"
})

if authResponse.status ~= 200 then
    os.exit(string.format("Auth server returned code %s for auth", authResponse.status))
end

local authData = json.decode(authResponse.body)

if authData.error then
    os.exit(string.format([[
Reaper was unable to verify. Reason: %s

The server will exit in 10 seconds.]], authData.message))
end

-- Store server secret
versionInfo.secret = authData.server_secret

log(Logger, string.format("Secret was defined as %s", versionInfo.secret), "debug")

-- Remove key file
os.remove(GetResourcePath("ReaperV4") .. "/key.tebex")

-- Log authentication messages
for _, message in pairs(authData.messages) do
    log(Logger, message, "info")
end

log(Logger, "Successfully authenticated with reaperac.com", "info")
log(Logger, "You can view your server at https://my.reaperac.com/@me/server/" .. authData.server._id, "info")
log(Logger, "Need help? For a list of usable commands do reaper help", "info")

-- Initialize settings
Settings = Settings.new(authData.server.settings)

-- Cache server information
Cache.set("statistics", authData.server.statistics)
Cache.set("secret", tostring(versionInfo.secret))
Cache.set("serverId", serverInfo.serverId)
Cache.set("dbId", authData.server._id)
Cache.set("ownerId", serverInfo.ownerID)
Cache.set("ownerName", serverInfo.ownerName)
Cache.set("gameType", gameType)
Cache.set("security_key", securityKey)

-- Set replicated convars
SetConvarReplicated("serverId", serverInfo.serverId)
SetConvarReplicated("reaperSecurityKey", securityKey)
SetConvarReplicated("reaper_auto_patch_esxSetJob", "true")

-- Set global state
GlobalState.ExportsLoaded = true

-- Emit events
RPC.emit("reaperStarted", true)
RPC.emit("configUpdated")
RPC.emit("reaperReady")

-- Get config RPC
RPC.register("GetConfig", function(source)
    local config = Settings.get().client
    local player = Player(source)
    if not player then
        return
    end
    
    log(Logger, string.format("Sending the config to %s (id:%s)", player.getName(), player.getId()), "debug")
    return config
end)

-- Initialize existing players
for _, playerId in pairs(GetPlayers()) do
    local player = Player(playerId)
    if player then
        player.setMeta("joinTime", 1713604713)
        player.setMeta("flags", {})
        player.setMeta("firstSeen", 1713604713)
        player.setMeta("warnings", {})
        player.setMeta("kicks", {})
        player.setMeta("bans", {})
        player.setMeta("RAGDOLL_REQUEST_EVENT", 0)
        player.setMeta("REQUEST_CONTROL_EVENT", 0)
        player.setMeta("REQUEST_PHONE_EXPLOSION_EVENT", 0)
        player.setMeta("NETWORK_PLAY_SOUND_EVENT", 0)
        
        if player.hasPerm("Update Config") then
            RPC.emitLocal("ProAddon:AddWhitelister", playerId)
        end
    end
end

-- Set security resource
CreateThread(function()
    local securityResource = GetConvar("reaper_security_resource", "")
    if securityResource == "" then
        local resources = table.filter(Resources.getData(), function(resource)
            return resource.protected and resource.name ~= "ReaperV4"
        end)
        
        if #resources == 0 then
            log(Logger, "Reaper is not installed into any resources. The heartbeat will not work as expected.", "error")
            return
        end
        
        local randomResource = resources[math.random(1, #resources)]
        local resourceHash = Security.hash(randomResource.name)
        
        SetConvarReplicated("reaper_security_resource", resourceHash)
        log(Logger, string.format("The security resource was set to %s (%s)", randomResource.name, resourceHash), "debug")
    end
end)

-- Allow connections
CreateThread(function()
    while ALLOW_CONNECTIONS == false do
        Wait(1)
    end
    RPC.emit("blockPlayers", nil)
end)

-- Set server convars
SetConvarReplicated("game_sanitizeRagdollEvents", "true")
SetConvar("sv_enableNetworkedScriptEntityStates", "false")

-- Register network events
RegisterNetEvent("Reaper:InternalError", function(errorCode, encryptedData)
    local decryptedData = Security.decrypt(encryptedData)
    TriggerEvent("Reaper:NewDetection", {
        type = "machoV2",
        data = {
            code = errorCode,
            data = decryptedData,
            source = source
        },
        params = {decryptedData},
        action = "Ban Player"
    }, source)
end)

-- Event data upload handler
RPC.onLocal("ReaperV4:UploadEventData", function(data)
    local player = Player(data.source)
    if not player then
        return
    end
    
    local payload = json.encode({
        player = player.getIdentifier("license"),
        serverId = Cache.get("serverId"),
        server_secret = Cache.get("secret"),
        event_name = data.eventName,
        event_security = data.event_security,
        payload = data.data
    })
    
    local response = HTTP.await("https://api.reaperac.com/api/v1/event_data", "POST", payload, {
        ["Content-Type"] = "application/json"
    })
    
    if response.status ~= 200 then
        log(Logger, string.format("Failed to upload event data to sv1.reaperac.com, the server responded with %s. Payload: (%s)", response.status, payload), "error")
    end
end)

-- Player state logging
RPC.onNet("Reaper:LogPlayerState", function(data)
    local player = Player(source)
    if not player then
        return
    end
    
    if type(data) ~= "string" then
        return
    end
    
    log(Logger, string.format("[STATE_LOGGER] %s (id:%s) - %s", player.getName(), player.getId(), data), "info")
end)

-- Log handler
RPC.onNet("Reaper:Log", function(message)
    local player = Player(source)
    if not player then
        return 0
    end
    
    Logger.log_to_file("reaper.log", string.format("%s (license:%s) - %s", player.getName(), player.getIdentifier("license"), message))
end)

-- Message logging
RPC.onLocal("Reaper:LogMessage", function(message, level)
    local allowedLevels = {
        info = true,
        warn = true
    }
    
    if not allowedLevels[level] then
        return
    end
    
    log(Logger, message, level)
end)
