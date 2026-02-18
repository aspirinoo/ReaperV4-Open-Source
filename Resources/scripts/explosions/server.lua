-- Reaper AntiCheat - Server Explosion System
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
local HTTP = HTTP
local GetGameTimer = GetGameTimer
local CancelEvent = CancelEvent
local tostring = tostring
local pairs = pairs
local table = table

-- Explosion type constants
local EXPLOSION_TYPES = {
    GRENADE = 0,
    GRENADELAUNCHER = 1,
    STICKYBOMB = 2,
    MOLOTOV = 3,
    ROCKET = 4,
    TANKSHELL = 5,
    HI_OCTANE = 6,
    CAR = 7,
    PLANE = 8,
    PETROL_PUMP = 9,
    BIKE = 10,
    DIR_STEAM = 11,
    DIR_FLAME = 12,
    DIR_WATER_HYDRANT = 13,
    DIR_GAS_CANISTER = 14,
    BOAT = 15,
    SHIP_DESTROY = 16,
    TRUCK = 17,
    BULLET = 18,
    SMOKEGRENADELAUNCHER = 19,
    SMOKEGRENADE = 20,
    BZGAS = 21,
    FLARE = 22,
    GAS_CANISTER = 23,
    EXTINGUISHER = 24,
    EXP_TAG_TRAIN = 26,
    EXP_TAG_BARREL = 27,
    EXP_TAG_PROPANE = 28,
    EXP_TAG_BLIMP = 29,
    EXP_TAG_DIR_FLAME_EXPLODE = 30,
    EXP_TAG_TANKER = 31,
    PLANE_ROCKET = 32,
    EXP_TAG_VEHICLE_BULLET = 33,
    EXP_TAG_GAS_TANK = 34,
    EXP_TAG_BIRD_CRAP = 35,
    EXP_TAG_RAILGUN = 36,
    EXP_TAG_BLIMP2 = 37,
    EXP_TAG_FIREWORK = 38,
    EXP_TAG_SNOWBALL = 39,
    EXP_TAG_PROXMINE = 40,
    EXP_TAG_VALKYRIE_CANNON = 41,
    EXP_TAG_AIR_DEFENCE = 42,
    EXP_TAG_PIPEBOMB = 43,
    EXP_TAG_VEHICLEMINE = 44,
    EXP_TAG_EXPLOSIVEAMMO = 45,
    EXP_TAG_APCSHELL = 46,
    EXP_TAG_BOMB_CLUSTER = 47,
    EXP_TAG_BOMB_GAS = 48,
    EXP_TAG_BOMB_INCENDIARY = 49,
    EXP_TAG_BOMB_STANDARD = 50,
    EXP_TAG_TORPEDO = 51,
    EXP_TAG_TORPEDO_UNDERWATER = 52,
    EXP_TAG_BOMBUSHKA_CANNON = 53,
    EXP_TAG_BOMB_CLUSTER_SECONDARY = 54,
    EXP_TAG_HUNTER_BARRAGE = 55,
    EXP_TAG_HUNTER_CANNON = 56,
    EXP_TAG_ROGUE_CANNON = 57,
    EXP_TAG_MINE_UNDERWATER = 58,
    EXP_TAG_ORBITAL_CANNON = 59,
    EXP_TAG_BOMB_STANDARD_WIDE = 60,
    EXP_TAG_EXPLOSIVEAMMO_SHOTGUN = 61,
    EXP_TAG_OPPRESSOR2_CANNON = 62,
    EXP_TAG_MORTAR_KINETIC = 63,
    EXP_TAG_VEHICLEMINE_KINETIC = 64,
    EXP_TAG_VEHICLEMINE_EMP = 65,
    EXP_TAG_VEHICLEMINE_SPIKE = 66,
    EXP_TAG_VEHICLEMINE_SLICK = 67,
    EXP_TAG_VEHICLEMINE_TAR = 68,
    EXP_TAG_SCRIPT_DRONE = 69,
    EXP_TAG_RAYGUN = 70,
    EXP_TAG_BURIEDMINE = 71,
    EXP_TAG_SCRIPT_MISSILE = 72,
    EXP_TAG_RCTANK_ROCKET = 73,
    EXP_TAG_BOMB_WATER = 74,
    EXP_TAG_BOMB_WATER_SECONDARY = 75,
    EXP_TAG_FLASHGRENADE = 78,
    EXP_TAG_STUNGRENADE = 79,
    EXP_TAG_SCRIPT_MISSILE_LARGE = 81,
    EXP_TAG_SUBMARINE_BIG = 82
}

-- Configuration variables
local logExplosionsToConsole = false
local blockAllExplosions = false
local blockInaudibleExplosions = false
local blockInvisibleExplosions = false
local blockUnknownExplosions = false
local autoExplosionWhitelist = false

-- Explosion data
local explosionData = {}
local blacklistedExplosions = {}

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
    local gameType = Cache.get("gameType")
    
    logExplosionsToConsole = config.explosionRules.logExplosionsToConsole
    blockAllExplosions = config.explosionRules.blockAllExplosions
    blockInaudibleExplosions = config.explosionRules.blockInaudibleExplosions
    blockInvisibleExplosions = config.explosionRules.blockInvisibleExplosions
    blockUnknownExplosions = config.explosionRules.blockUnknownExplosions
    
    autoExplosionWhitelist = GetConvar("reaper_auto_explosion_whitelist", "false") == "true"
    
    SetConvar("sv_enableNetworkedPhoneExplosions", tostring(not blockAllExplosions))
    
    -- Load explosion data from API
    if #json.encode(explosionData) == 2 then
        local explosionResponse = HTTP.await("https://api.reaperac.com/api/v1/data/explosions?game=" .. gameType)
        if explosionResponse and explosionResponse.body then
            explosionData = json.decode(explosionResponse.body)
        end
    end
    
    -- Process blacklisted explosions
    blacklistedExplosions = {}
    for _, rule in pairs(config.explosionRules.blacklisted) do
        local explosionType = tostring(rule.type)
        if not blacklistedExplosions[explosionType] then
            blacklistedExplosions[explosionType] = {}
        end
        table.insert(blacklistedExplosions[explosionType], {
            action = rule.action
        })
    end
end)

-- Initialize explosion system
RPC.on("reaperStarted", function()
    local gameType = Cache.get("gameType")
    
    -- Explosion event handler
    RPC.onLocal("explosionEvent", function(source, explosionData)
        local explosionType = explosionData.explosionType
        
        -- Handle water hydrant explosions
        if explosionType == 13 then
            Cache.set("last_water_hydrant_hit", GetGameTimer())
        end
        
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        local explosionName = explosionData[tostring(explosionType)]
        if not explosionName then
            explosionName = explosionType
        end
        
        -- Check if all explosions are blocked
        if not blockAllExplosions then
            local rateLimit = player.getMeta("explosion_ratelimit", 0)
            if rateLimit > 0 then
                CancelEvent()
                return
            end
        end
        
        -- Log explosion
        player.NewLog("^3%s ^7(^3id:%s^7) just spawned a new explosion. Explosion Type: ^3%s^7", "info", "explosions", {
            explosionName = explosionName,
            explosionType = explosionType
        }, not logExplosionsToConsole)
        
        -- Check for unknown explosions
        if blockUnknownExplosions then
            local knownExplosion = explosionData[tostring(explosionType)]
            if not knownExplosion then
                CancelEvent()
                player.NewLog("^3%s ^7(^3id:%s^7) just spawned an unknown explosion. Hash: ^3%s^7", "info", "explosion", {
                    explosionName = explosionName,
                    explosionType = explosionType
                })
            end
        end
        
        -- Check for invisible explosions
        if explosionData.isInvisible and blockInvisibleExplosions then
            CancelEvent()
            player.NewLog("^3%s ^7(^3id:%s^7) just spawned an invisible explosion. Explosion Type: ^3%s^7", "info", "explosion", {
                explosionName = explosionName,
                explosionType = explosionType
            })
        end
        
        -- Check for inaudible explosions
        if not explosionData.isAudible and blockInaudibleExplosions then
            CancelEvent()
            player.NewLog("^3%s ^7(^3id:%s^7) just spawned an inaudible explosion. Explosion Type: ^3%s^7", "info", "explosion", {
                explosionName = explosionName,
                explosionType = explosionType
            })
        end
        
        -- Check auto whitelist
        if autoExplosionWhitelist then
            local explosiveWeapons = WeaponsList.ExplosiveWeapons
            local weaponData = explosiveWeapons[explosionType]
            if weaponData then
                local playerWeapon = player.getWeapon()
                if not weaponData[playerWeapon] then
                    CancelEvent()
                    player.NewLog("^3%s ^7(^3id:%s^7) attempted to spawn an explosion without authorization. Explosion Type: ^3%s^7", "warn", "explosion", {
                        explosionName = explosionName,
                        explosionType = explosionType,
                        explosionEvent = explosionData,
                        current_weapon = player.getWeapon()
                    })
                end
            else
                CancelEvent()
            end
        end
        
        -- Check blacklisted explosions
        local explosionTypeStr = tostring(explosionType)
        local blacklistRules = blacklistedExplosions[explosionTypeStr] or {}
        
        for _, rule in pairs(blacklistRules) do
            CancelEvent()
            if rule.action ~= "none" then
                RPC.emitLocal("Reaper:NewDetection", {
                    type = "blacklistedExplosion",
                    data = {
                        rule = rule,
                        explosion = explosionType,
                        name = explosionName
                    },
                    params = {explosionName},
                    action = rule.action
                }, player.getId())
            end
        end
    end)
    
    -- Projectile event handler
    RPC.onLocal("startProjectileEvent", function(source, projectileData)
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        player.NewLog("^3%s^7 (^3id:%s^7) just spawned a new projectile. Data: ^3%s^7", "warn", "projectiles", projectileData, GetConvar("reaper_log_projectile_events", "false") == "true")
        
        -- Check weapon hash mismatch
        if projectileData.weaponHash ~= player.getWeapon() then
            local blockMismatch = GetConvar("reaper_projectile_missmatch_blocks", "true")
            if blockMismatch == "true" then
                player.NewLog("^3%s^7 (^3id:%s^7) just spawned a new projectile but was blocked due to weaponHash mismatch. Projectile: ^3%s^7", "warn", "projectiles", projectileData)
                CancelEvent()
                return
            end
        end
    end)
end)