-- Reaper AntiCheat - Server Particle System
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
local RPC = RPC
local Logger = Logger
local Player = Player
local Cache = Cache
local Settings = Settings
local GetGameTimer = GetGameTimer
local CancelEvent = CancelEvent
local GetHashKey = GetHashKey
local tostring = tostring
local tonumber = tonumber
local pairs = pairs
local SetConvarReplicated = SetConvarReplicated

-- Configuration variables
local particleWhitelistEnabled = false
local autoParticleWhitelist = false
local blockAllParticles = false
local logParticlesToConsole = false
local nonWhitelistedParticleAction = "Ban Player"
local whitelistedParticles = {}
local blacklistedParticles = {}
local particleRatelimits = {}

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

-- Configuration update handler
RPC.on("configUpdated", function()
    local config = Settings.get()
    
    particleWhitelistEnabled = config.particleRules.particleWhitelistEnabled
    autoParticleWhitelist = config.particleRules.autoParticleWhitelist
    blockAllParticles = config.particleRules.blockAllParticles
    logParticlesToConsole = config.particleRules.logParticlesToConsole
    nonWhitelistedParticleAction = config.particleRules.nonWhitelistedParticleAction
    blacklistedParticles = config.particleRules.blacklisted
    particleRatelimits = config.particleRules.particleRatelimits
    
    -- Process whitelisted particles
    whitelistedParticles = {}
    for _, particle in pairs(config.particleRules.whitelisted) do
        local particleHash = tonumber(particle)
        if not particleHash then
            particleHash = GetHashKey(particle)
        end
        whitelistedParticles[tostring(particleHash)] = true
    end
    
    -- Set replicated convar for auto whitelist
    SetConvarReplicated("auto_particle_whitelist", tostring(autoParticleWhitelist))
end)

-- Initialize particle system
RPC.on("reaperStarted", function()
    local gameType = Cache.get("gameType")
    
    -- Particle effect event handler
    RPC.onNet("ptFxEvent", function(source, particleData)
        CancelEvent()
        
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        -- Block all particles if enabled
        if blockAllParticles then
            CancelEvent()
            return
        end
        
        -- Log particle spawn
        player.NewLog("^3%s^7 (^3id:%s^7) just spawned a new particle. Particle hash: ^3%s", "info", "particles", {}, not logParticlesToConsole)
        
        -- Check for temporary whitelist
        local isWhitelisted = player.getMeta("whitelisted_particle_" .. particleData.effectHash)
        if not isWhitelisted then
            local currentTime = GetGameTimer()
            local tempWhitelistTime = player.getMeta("whitelist_particle_temp", 0)
            
            if currentTime - tempWhitelistTime < 10000 then
                player.setMeta("whitelisted_particle_" .. particleData.effectHash, true)
            end
        end
        
        -- Check whitelist if enabled
        if particleWhitelistEnabled then
            local particleHash = tostring(particleData.effectHash)
            local isInWhitelist = whitelistedParticles[particleHash]
            
            if not isInWhitelist then
                local isPlayerWhitelisted = player.getMeta("whitelisted_particle_" .. particleData.effectHash)
                if not isPlayerWhitelisted then
                    CancelEvent()
                    RPC.emitLocal("Reaper:NewDetection", {
                        type = "particleWhitelist",
                        data = {
                            effectHash = particleData.effectHash
                        },
                        params = {particleData.effectHash},
                        action = "Ban Player"
                    }, player.getId())
                    return
                end
            end
        end
        
        -- Check blacklist
        local isBlacklisted = blacklistedParticles[particleData.effectHash]
        if isBlacklisted then
            CancelEvent()
            RPC.emitLocal("Reaper:NewDetection", {
                type = "blacklistedParticle",
                data = {
                    effectHash = particleData.effectHash
                },
                params = {particleData.effectHash},
                action = nonWhitelistedParticleAction
            }, player.getId())
            return
        end
    end)
    
    -- Request particle spawn handler
    RPC.register("requestParticleSpawn", function(source, effectName, effectHash, executionId, extendedExecutionId)
        local player = Player(source)
        if not player then
            return false
        end
        
        if not autoParticleWhitelist then
            return false
        end
        
        -- Validate execution context
        if not ExecutionCheck.execution_valid(player.getId(), "StartNetworkedParticleFx", executionId, effectHash, extendedExecutionId, effectName or "0") then
            return false
        end
        
        -- Set temporary whitelist
        player.setMeta("whitelist_particle_temp", GetGameTimer())
        
        -- Log particle request
        player.NewLog("^3%s^7 (^3id:%s^7) just requested to spawn a particle (^3%s^7) from (^3%s^7) (^3%s^7)", "debug", "particles", {})
        
        return true
    end)
end)