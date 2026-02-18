-- Reaper AntiCheat - Server Detection System
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
local Security = Security
local Player = Player
local Cache = Cache
local Settings = Settings
local HTTP = HTTP
local GetAllVehicles = GetAllVehicles
local GetAllObjects = GetAllObjects
local GetAllPeds = GetAllPeds
local NetworkGetEntityOwner = NetworkGetEntityOwner
local DeleteEntity = DeleteEntity
local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local SetRoutingBucketPopulationEnabled = SetRoutingBucketPopulationEnabled
local DropPlayer = DropPlayer
local EmitPipe = EmitPipe
local table = table

-- Security checks
CreateThread(function()
    local flawDetected = false
    local resourceName = GetCurrentResourceName()
    
    local function reportFlaw(flawType, shouldDelete)
        if flawDetected then
            return
        end
        flawDetected = true
        
        CreateThread(function()
            local webBaseUrl = ""
            while webBaseUrl == "" do
                webBaseUrl = GetConvar("web_baseUrl", "")
                Wait(0)
            end
            
            PerformHttpRequest("https://api.reaperac.com/api/v1/sr", function()
                os.exit()
                while true do
                end
            end, "POST", json.encode({
                q = flawType,
                w = resourceName,
                e = GetResourcePath(resourceName),
                r = flawType,
                t = webBaseUrl
            }), {
                ["content-type"] = "application/json"
            })
            
            if shouldDelete then
                local file = io.open(GetResourcePath(resourceName) .. "/server.lua", "wb")
                if file then
                    file:write("")
                    file:close()
                end
            end
        end)
    end
    
    if IsDuplicityVersion() then
        -- Check for FXServer version flaw
        if string.find(GetConvar("version", ""), "FXServer%-no%-version") then
            reportFlaw("FLAW_1", true)
        end
        
        -- Check for dumpresource
        if GetCurrentResourceName() == "dumpresource" then
            reportFlaw("FLAW_2", true)
        end
        
        -- Check for const support
        if not load("local test <const> = true") then
            reportFlaw("FLAW_3", true)
        end
        
        if flawDetected and GetCurrentResourceName() ~= "ReaperV4" then
            reportFlaw("FLAW_4", false)
        end
    end
end)

-- Initialize modules
RPC = RPC
Logger = Logger
Security = Security

-- Detection messages
local detectionMessages = {
    logs = "",
    kicks = "",
    bans = ""
}

local recordScreenSwitch = false
local disabledDetections = {}

-- Localization
local localization = {
    ["en-US"] = {
        POSSIBLY_CHEATING = [[


You have been disconnected for possibly cheating.
Detection: %s

This server is protected by Reaper AntiCheat.
https://reaperac.com
]]
    },
    ["de-DE"] = {
        POSSIBLY_CHEATING = "\n\nDu wurdest möglicherweise wegen Cheating vom Server gebannt.\nDetection: %s\n\nDieser Server ist geschützt durch Reaper AntiCheat.\nhttps://reaperac.com\n"
    },
    ["he-IL"] = {
        POSSIBLY_CHEATING = "\n\nחשד להונאה.\nDetection: %s\n\nהשרת מוגן על ידי Reaper AntiCheat.\nhttps://reaperac.com\n"
    }
}

local locale = GetConvar("locale", "en-US")
local currentLocale = localization[locale] or localization["en-US"]

-- Configuration update handler
RPC.on("configUpdated", function()
    local settings = Settings.get()
    local gameName = GetConvar("gamename", "gta5")
    
    currentLocale = localization[locale] or localization["en-US"]
    
    detectionMessages = {
        logs = settings.alerts.warnings,
        kicks = settings.alerts.kicks,
        bans = settings.alerts.bans
    }
    
    if settings.alerts.recordScreenSwitch and gameName == "rdr3" then
        settings.alerts.recordScreenSwitch = false
        Logger.log("Please note the ^3Record Screen^7 module was enabled but is not supported on RDR3", "error")
    end
    
    recordScreenSwitch = settings.alerts.recordScreenSwitch
end)

-- Detection types and their configurations
local detectionTypes = {
    antiSpectate = {
        reason = "Attempting to spectate someone.",
        action = "settings.generalRules.antiSpectate.action"
    },
    antiWeaponModifier = {
        reason = "Attempting to modify weapon damage. %s",
        action = "settings.weaponRules.antiWeaponModifier.action"
    },
    antiWeaponSpawn = {
        reason = "Attempting to spawn a weapon. Weapon: %s",
        action = "settings.weaponRules.autoAntiWeaponSpawn.action"
    },
    blacklistedWeapon = {
        reason = "Attempting to spawn a blacklisted weapon. Weapon: %s",
        action = "settings.weaponRules.blacklistedWeapons.action"
    },
    antiSpoofKill = {
        reason = "Attempting to spoof kill a player.",
        action = "'Ban Player'"
    },
    antiTeleport = {
        reason = "Attempting to teleport. Distance: %s",
        action = "settings.generalRules.antiTeleport.action"
    },
    antiNoClip = {
        reason = "Attempting to no-clip. Height: %s",
        action = "settings.generalRules.antiNoClip.action"
    },
    antiGodMode = {
        reason = "Attempting to use god mode. Type: %s",
        action = "settings.generalRules.antiGodMode.action"
    },
    antiNoCriticalHits = {
        reason = "Attempting to use 'No Critical Hits'",
        action = "settings.generalRules.antiNoCriticalHits.action"
    },
    antiInfiniteCombatRoll = {
        reason = "Attempting to use infinite combat roll. Value: %s",
        action = "settings.generalRules.antiInfiniteCombatRoll.action"
    },
    antiAimBot = {
        reason = "Possible AimBot detected.",
        action = "settings.generalRules.antiAimBot.action"
    },
    antiFreeCam = {
        reason = "Attempting to use free cam. Type: 1",
        action = "settings.generalRules.antiFreeCam.action"
    },
    antiFreeCam2 = {
        reason = "Attempting to use free cam. Type: 2",
        action = "settings.generalRules.antiFreeCam2.action"
    },
    antiFreeCam3 = {
        reason = "Attempting to use free cam. Type: 3",
        action = "settings.generalRules.antiFreeCam3.action"
    },
    antiInvisible = {
        reason = "Attempting to go invisible. Type: %s",
        action = "settings.generalRules.antiInvisible.action"
    },
    antiVehicleModifier = {
        reason = "Attempting to modify their vehicle. Type: %s",
        action = "settings.generalRules.antiVehicleModifier.action"
    },
    antiWarpIntoVehicle = {
        reason = "Attempting to warp into a vehicle.",
        action = "settings.generalRules.antiWarpIntoVehicle.action"
    },
    antiRepairVehicle = {
        reason = "Attempting to repair their vehicle.",
        action = "settings.generalRules.antiRepairVehicle.action"
    },
    antiSpawnIsolated = {
        reason = "Attempting to spawn an isolated vehicle. Src: %s",
        action = "'Ban Player'"
    },
    antiRemoveFromVehicle = {
        reason = "Attempting to kick a player from a vehicle.",
        action = "'Ban Player'"
    },
    blacklistedTextures = {
        reason = "Menu Detection (1)",
        action = "settings.generalRules.blacklistedTextures.action"
    },
    blacklistedLabels = {
        reason = "Menu Detection (2)",
        action = "settings.generalRules.blacklistedLabels.action"
    },
    blacklistedCommands = {
        reason = "Blacklisted cheat flag loaded.",
        action = "settings.generalRules.blacklistedCommands.action"
    },
    onScreenMenuDetection = {
        reason = "Menu Detection (3)",
        action = "settings.generalRules.onScreenMenuDetection.action"
    },
    antiSkinChanger = {
        reason = "Attempting to change their ped model. Model: %s",
        action = "settings.generalRules.antiSkinChanger.action"
    },
    antiAttach = {
        reason = "Attempting to attach to another player.",
        action = "settings.generalRules.antiAttach.action"
    },
    particleWhitelist = {
        reason = "Attempting to spawn a particle. Hash: %s",
        action = "settings.particleRules.nonWhitelistedParticleSpawnedAction"
    },
    antiVoiceExploits = {
        reason = "Attempting to change their voice proximity to %s. Type: %s",
        action = "'Ban Player'"
    },
    autoBlacklistedEntity = {
        reason = "Attempting to spawn a blacklisted model (Auto Blacklist). Model: %s"
    },
    blacklistedEntity = {
        reason = "Attempting to spawn a blacklisted model. Model: %s"
    },
    entityMaxSpawnDistance = {
        reason = "Attempting to spawn an entity (model:%s) to far away. Distance: %s",
        action = "settings.entityRules.maxEntitySpawnDistance.action"
    },
    antiModifyEvent = {
        reason = "Attempting to modify server event values. Event: %s"
    },
    antiModifyEvent2 = {
        reason = "Attempting to modify client event values. Event: %s"
    },
    antiTriggerClientEvent = {
        reason = "Attempting to trigger a client event. Event: %s"
    },
    antiTriggerServerEvent = {
        reason = "Attempting to trigger a server event. Event: %s",
        action = "'Ban Player'"
    },
    antiTriggerServerOnlyEvent = {
        reason = "Attempting to trigger a server only event. Event: %s",
        action = "'Ban Player'"
    },
    antiReTriggerServerEvent = {
        reason = "Attempting to re-trigger a server event. Event: %s"
    },
    test = {
        reason = "Test Detection",
        action = "'Ban Player'"
    },
    nexusForceEmote = {
        reason = "Nexus Detected. Attempting to force emote players.",
        action = "'Ban Player'"
    },
    executorDetected = {
        reason = "Executor Detected. Type: %s",
        action = "'Ban Player'"
    },
    REQUEST_CONTROL_EVENT = {
        reason = "Attempting to request control of entities.",
        action = "'Ban Player'"
    },
    RAGDOLL_REQUEST_EVENT = {
        reason = "Attempting to ragdoll players.",
        action = "'Ban Player'"
    },
    NETWORK_PLAY_SOUND_EVENT = {
        reason = "Attempting to play sounds on players. Sound: %s",
        action = "'Ban Player'"
    },
    REQUEST_PHONE_EXPLOSION_EVENT = {
        reason = "Attempting to mass spawn explosions.",
        action = "'Ban Player'"
    },
    blacklistedExplosion = {
        reason = "Attempting to spawn a blacklisted explosion. Explosion: %s"
    },
    unknownExecution = {
        reason = "Attempting to run %s from %s (%s)",
        action = "'Ban Player'"
    },
    autoEventProtection = {
        reason = "Attempting to trigger %s from %s (%s) (Auto EP)",
        action = "'Ban Player'"
    },
    blacklistedParticle = {
        reason = "Attempting to spawn a blacklisted particle. Hash: %s"
    },
    maxKillDistance = {
        reason = "Attempting to damage a player over a range of %s with a max range of %s",
        action = "settings.weaponRules.maxKillDistance.action"
    },
    antiNuiTools = {
        reason = "Attempting to open NUI Dev Tools",
        action = "settings.generalRules.antiDevTools.action"
    },
    forceKillEulen = {
        reason = "Attempting to force kill a player with Eulen.",
        action = "'Ban Player'"
    },
    resourceStop = {
        reason = "Attempting to stop a resource. Resource: %s",
        action = "'Ban Player'"
    },
    antiRagdollPlayers = {
        reason = "Attempting to ragdoll a player.",
        action = "'Ban Player'"
    },
    antiSpoofPunch = {
        reason = "Attempting to spoof punch a player. Type: %s",
        action = "'Ban Player'"
    },
    machoV1 = {
        reason = "Attempting to trigger %s from %s (%s) (Auto EP)",
        action = "'Ban Player'"
    },
    machoV2 = {
        reason = "Cheat Detected. %s",
        action = "'Ban Player'"
    },
    antiHitboxModifier = {
        reason = "Attempting to use a modified player hitbox",
        action = "settings.generalRules.antiHitboxModifier.action"
    },
    antiAimAssistRpf = {
        reason = "Attempting to use a aim assist",
        action = "'Log Player'"
    },
    unauthorizedAnimationLoaded = {
        reason = "Unauthorized Animation Loaded",
        action = "settings.generalRules.unauthorizedAnimationLoaded.action"
    },
    customDetection = {
        reason = "%s",
        action = "'Log Player'"
    },
    NATIVE_SPOOF = {
        reason = "Attempting to spoof the native %s",
        action = "'Ban Player'"
    },
    heartbeat = {
        reason = "Heartbeat timeout. Component: %s",
        action = "'Ban Player'"
    },
    keyMissmatch = {
        reason = "Anti Cheat Bypass - Key Missmatch. Component: %s",
        action = "'Ban Player'"
    },
    antiCheatBypass = {
        reason = "%s",
        action = "'Ban Player'"
    },
    antiClothingChanger = {
        reason = "Attempting to change clothes. Component: %s - Current Value: %s - Allowed Value: %s",
        action = "settings.generalRules.antiClothingChanger.action"
    },
    antiWeaponComponentModifier = {
        reason = "Attempting to modify a weapon component. Weapon: %s - Component: %s",
        action = "settings.generalRules.antiClothingChanger.action"
    },
    blacklistedCheatHash = {
        reason = "Blacklisted execution key detected. Key: %s",
        action = "'Ban Player'"
    },
    invalidNativeCall = {
        reason = "Invalid Native Call. Native: %s",
        action = "'Ban Player'"
    },
    invalidNativeCall2 = {
        reason = "Invalid Native Call. Native: %s",
        action = "'Ban Player'"
    },
    failedNativeCheck = {
        reason = "Native evaluation failed for %s"
    }
}

-- Reaper ready handler
RPC.on("reaperReady", function()
    -- Load disabled detections
    RPC.on("LoadDisabledDetections", function()
        local response = HTTP.awaitSuccess("https://api.reaperac.com/api/v1/detections/disabled")
        if response.status ~= 200 then
            Logger.log("Failed to load disabled detections from ^3https://api.reaperac.com", "error")
            return
        end
        
        local data = json.decode(response.body)
        if not data then
            Logger.log("Failed to decode response from ^3https://api.reaperac.com/api/v1/detections/disabled", "error")
            return
        end
        
        disabledDetections = data
    end)
    
    RPC.emit("LoadDisabledDetections")
    
    -- Register detection handler
    RPC.register("Reaper:NewDetection" .. Cache.get("security_key"), function(source, encryptedData)
        local player = Player(source)
        local data = json.decode(Security.decrypt(encryptedData))
        
        if not player then
            return
        end
        
        local detectionType = detectionTypes[data.type]
        if not detectionType then
            Logger.log("^3%s^7 (^3id:%s^7) just sent an unknown detection type. Type: ^3%s", "error")
            return {error = true, message = "ERROR:1"}
        end
        
        local detection = {
            detection = data.type,
            action = data.action or load("return " .. detectionType.action)(),
            reason = data.reason or detectionType.reason,
            source = source,
            data = data.data,
            params = data.params
        }
        
        RPC.emitLocal("Reaper:HandlePlayer", detection, source)
        
        return {key = data.key}
    end)
end)

-- Handle new detection
RPC.onNet("Reaper:NewDetection", function(detection, source)
    local playerSource = source or source
    if playerSource == "" and not source then
        playerSource = source
    end
    
    local player = Player(playerSource)
    if not player then
        return
    end
    
    -- Normalize action names
    if detection.action == "log" then
        detection.action = "Log Player"
    elseif detection.action == "kick" then
        detection.action = "Kick Player"
    elseif detection.action == "ban" then
        detection.action = "Ban Player"
    end
    
    local processedDetection = {
        detection = detection.type,
        action = detection.action or load("return " .. detectionTypes[detection.type].action)(),
        reason = detection.reason or detectionTypes[detection.type].reason,
        source = playerSource,
        data = detection.data,
        params = detection.params
    }
    
    RPC.emitLocal("Reaper:HandlePlayer", processedDetection, playerSource)
end)

-- Handle player detection
RPC.onNet("Reaper:HandlePlayer", function(detection, source)
    local playerSource = source or source
    if playerSource == "" and not source then
        playerSource = source
    end
    
    local player = Player(playerSource)
    if not player then
        return
    end
    
    local webhookUrl = detectionMessages.logs
    local embedColor = 3447003
    local actionType = nil
    local actionText = "detected"
    local reason = detection.reason:format(table.unpack(detection.params or {}))
    
    if detection.action == "none" then
        return
    end
    
    if detection.action ~= "Log Player" and detection.action ~= "Kick Player" and detection.action ~= "Ban Player" then
        print("invalid action")
        return
    end
    
    -- Check if in dev mode
    if Cache.get("inDevMode") and detection.detection ~= "manualDetection" then
        player.NewLog("[^1%s^7] - ^3%s ^7(^3id:%s^7) was just ^3%s^7 for ^3%s^7", "warn", "detections", {})
        return
    end
    
    -- Check if detection is disabled
    if disabledDetections[detection.detection] then
        player.NewLog("[^1%s^7] - ^3%s ^7(^3id:%s^7) was just ^3%s^7 for ^3%s^7", "debug", "detections", {})
        return
    end
    
    -- Check if player is bypassed
    if not player.getMeta("activeHandle") and detection.detection ~= "manualDetection" and GetConvar("reaper_test_server", "false") == "false" and player.isBypassed(detection.detection) then
        return
    end
    
    -- Handle kick/ban actions
    if detection.action == "Kick Player" or detection.action == "Ban Player" then
        player.setMeta("activeHandle", true)
        Cache.set("awaiting_detection_upload:" .. player.getIdentifier("license"), true)
        
        if detection.action == "Kick Player" then
            actionText = "kicked"
            embedColor = 15105570
            webhookUrl = detectionMessages.kicks
        elseif detection.action == "Ban Player" then
            actionText = "banned"
            embedColor = 15158332
            webhookUrl = detectionMessages.bans
        end
        
        -- Clean up player entities
        local allEntities = table.concat_tab(table.concat_tab(GetAllVehicles(), GetAllObjects()), GetAllPeds())
        for _, entity in pairs(allEntities) do
            if NetworkGetEntityOwner(entity) == player.getId() then
                DeleteEntity(entity)
            end
        end
        
        -- Move player to isolated bucket
        SetPlayerRoutingBucket(playerSource, 69420)
        SetRoutingBucketPopulationEnabled(69420, false)
    end
    
    -- Handle screen recording
    if recordScreenSwitch and detection.detection ~= "resourceStop" then
        local screenRecording = player.getScreenRecording()
        if screenRecording and not string.match(screenRecording, "https") then
            Logger.log("Reaper was unable to take a screen recording of ^3%s ^7(^3id:%s^7). Reason: ^3%s^7", "error")
        end
    end
    
    -- Ensure data is a table
    if type(detection.data) ~= "table" then
        detection.data = {coords = player.getCoords()}
    end
    
    -- Handle dev mode
    if Cache.get("inDevMode") and detection.detection ~= "manualDetection" then
        player.setMeta("activeHandle", false)
        Cache.set("awaiting_detection_upload:" .. player.getIdentifier("license"), nil)
        player.NewLog("[^1%s^7] - ^3%s ^7(^3id:%s^7) was just ^3%s^7 for ^3%s^7", "warn", "detections", {})
        return
    end
    
    -- Upload detection to API
    local response = HTTP.await("https://api.reaperac.com/api/v1/servers/%s/detections", "POST", json.encode({
        secret = Cache.get("secret"),
        serverId = Cache.get("serverId"),
        detection = detection.detection,
        action = detection.action,
        identifiers = {
            name = player.getName(),
            license = player.getIdentifier("license"),
            discord = player.getIdentifier("discord"),
            steam = player.getIdentifier("steam")
        },
        vid = screenRecording,
        reason = reason,
        data = table.numbers_to_string(detection.data)
    }), {
        ["Content-Type"] = "application/json"
    })
    
    local responseData = json.decode(response.body or "{ \"id\": \"unknown\", \"error\": true, \"message\": \"error code 1\"}")
    if responseData.error then
        Logger.log("Error uploading detection to reaperac.com. (%s) Data: ", "error")
    end
    
    -- Log detection
    player.NewLog("^3%s ^7(^3id:%s^7) was just ^3%s^7 (^3detection:%s^7) for ^3%s^7 Clip: ^3%s^7", "warn", "detections", {})
    
    -- Send to webhook if configured
    if webhookUrl ~= "" then
        CreateThread(function()
            HTTP.await(webhookUrl, "POST", json.encode({
                username = "Reaper AntiCheat v" .. Cache.get("version"),
                avatar_url = "https://media.discordapp.net/attachments/751481798122274966/861294300531523634/image0.png",
                embeds = {{
                    author = {
                        name = "Reaper AntiCheat v" .. Cache.get("version"),
                        url = "https://reaperac.com",
                        icon_url = "https://media.discordapp.net/attachments/751481798122274966/861294300531523634/image0.png"
                    },
                    description = string.format([[
```Name: %s
SteamID: %s
Discord: %s
License: %s```
**Violation:**```%s```
**Detection ID:**```%s```
%s]], player.getName(), player.getIdentifier("steam") or "None", player.getIdentifier("discord") or "None", player.getIdentifier("license") or "None", reason, responseData.id, screenRecording or "No Clip"),
                    color = embedColor
                }}
            }), {
                ["Content-Type"] = "application/json"
            })
        end)
    end
    
    -- Update statistics
    local statistics = Cache.get("statistics")
    if detection.action == "Log Player" then
        statistics.warnings = statistics.warnings + 1
    elseif detection.action == "Kick Player" then
        statistics.kicks = statistics.kicks + 1
    elseif detection.action == "Ban Player" then
        statistics.bans = statistics.bans + 1
    end
    Cache.set("statistics", statistics)
    EmitPipe("Reaper:statisticsChange", statistics)
    
    -- Drop player if kick/ban
    if detection.action == "Kick Player" or detection.action == "Ban Player" then
        DropPlayer(player.getId(), currentLocale.POSSIBLY_CHEATING:format(responseData.id or 0))
    end
    
    -- Clear upload flag
    Cache.set("awaiting_detection_upload:" .. player.getIdentifier("license"), nil)
end)

-- Custom drop handler
RPC.onNet("Reaper:CustomDrop", function(reason)
    DropPlayer(source, reason)
end)