-- Reaper AntiCheat - Server OneSync System
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
local GetPlayers = GetPlayers
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local GetEntityCoords = GetEntityCoords
local GetDistanceBetweenCoords = GetDistanceBetweenCoords
local Wait = Wait
local pairs = pairs
local table = table
local tostring = tostring
local type = type
local vec3 = vec3

-- Configuration variables
local whitelistedSounds = {}
local antiSoundExploits = false
local antiNativeSpoofer = false
local blockAllFireEvents = false
local autoFireWhitelist = false

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
    local customBuild = GetConvar("sv_reaper_custom_build", "false") == "true"
    
    antiSoundExploits = config.generalRules.antiSoundExploits
    whitelistedSounds = config.generalRules.whitelisted_sounds or {}
    
    if not antiSoundExploits then
        SetConvar("sv_enableNetworkedSounds", tostring(not config.generalRules.antiSoundExploits))
        SetConvarReplicated("reaper_auto_bypass_play_sound", "false")
    else
        SetConvar("sv_enableNetworkedSounds", "true")
        SetConvarReplicated("reaper_auto_bypass_play_sound", "true")
    end
    
    antiNativeSpoofer = config.generalRules.antiNativeSpoofer.enabled
    blockAllFireEvents = GetConvar("reaper_block_all_fire_events", "true") == "true"
    autoFireWhitelist = GetConvar("reaper_auto_fire_whitelist", "false") == "true"
end)

-- Initialize OneSync system
RPC.on("reaperStarted", function()
    -- Request play sound handler
    RPC.register("requestPlaySound", function(source, soundName, soundRef, executionId, extendedExecutionId)
        local player = Player(source)
        if not player then
            return false
        end
        
        if not antiSoundExploits then
            return false
        end
        
        player.NewLog("^3%s^7 (^3id:%s^7) just requested to play the sound (^3%s^7) from ^3%s^7 (^3%s^7)", "debug", "sound_events", {})
        
        if not ExecutionCheck.execution_valid(player.getId(), "PlaySound", executionId, soundRef, extendedExecutionId, soundName or "0") then
            return false
        end
        
        player.setMeta("temp_allow_playSound", GetGameTimer())
        return true
    end)
    
    -- Network play sound event handler
    RPC.onLocal("networkPlaySoundEvent", function(source, soundData)
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        if not antiSoundExploits then
            return
        end
        
        local currentTime = GetGameTimer()
        local tempAllowTime = player.getMeta("temp_allow_playSound", 0)
        
        if currentTime - tempAllowTime < 10000 then
            player.setMeta("allowed_soundRef_" .. soundData.audioHash, true)
            player.setMeta("allowed_soundRef_" .. soundData.audioRefHash, true)
        end
        
        local isAudioAllowed = player.getMeta("allowed_soundRef_" .. soundData.audioHash, false)
        local isRefAllowed = player.getMeta("allowed_soundRef_" .. soundData.audioRefHash, false)
        
        if not isAudioAllowed and not isRefAllowed then
            CancelEvent()
            player.NewLog("^3%s^7 (^3id:%s^7) just started playing a sound without authorization (^3%s^7)", "warn", "sound_events", {})
            
            local banPlaySounds = GetConvar("reaper_ban_play_sounds", "true")
            if banPlaySounds == "true" then
                local soundHash = tostring(soundData.audioHash)
                if not whitelistedSounds[soundHash] then
                    RPC.emitLocal("Reaper:NewDetection", {
                        type = "NETWORK_PLAY_SOUND_EVENT",
                        data = soundData,
                        params = {soundData.audioHash},
                        action = "Ban Player"
                    }, player.getId())
                end
            end
        end
        
        player.NewLog("^3%s^7 (^3id:%s^7) just started playing the sound ^3%s^7", "info", "sound_events", soundData, GetConvar("reaper_log_sound_events", "false") ~= "true")
    end)
    
    -- Request network start sync scene handler
    RPC.register("requestNetworkStartSyncScene", function(source, sceneData)
        local player = Player(source)
        if not player then
            return false
        end
        
        player.setMeta("temp_allow_networkStartSyncScene", GetGameTimer())
        return true
    end)
    
    -- Request network synced scene event handler
    RPC.onLocal("requestNetworkSyncedSceneEvent", function(source, sceneData)
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        local currentTime = GetGameTimer()
        local tempAllowTime = player.getMeta("temp_allow_networkStartSyncScene", 0)
        
        if currentTime - tempAllowTime > 5000 then
            local blockUnauthorized = GetConvar("reaper_block_unauthorized_networked_scenes", "true")
            if blockUnauthorized == "true" then
                CancelEvent()
                local logRequest = GetConvar("reaper_request_networked_synced_scene_f_a", "false")
                if logRequest == "true" then
                    Logger.log("^3%s^7 (^3id:%s^7) just requested a new networked scene event without authorization. Data: ^3%s", "warn")
                end
            end
        end
        
        local logStart = GetConvar("reaper_log_start_networked_scene_events", "false")
        if logStart == "true" then
            Logger.log("^3%s^7 (^3id:%s^7) just emitted requestNetworkSyncedSceneEvent. Data: ^3%s", "warn")
        end
    end)
    
    -- Start network synced scene event handler
    RPC.onLocal("startNetworkSyncedSceneEvent", function(source, sceneData)
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        local logStart = GetConvar("reaper_log_start_networked_scene_events", "false")
        if logStart == "true" then
            Logger.log("^3%s^7 (^3id:%s^7) just emitted startNetworkSyncedSceneEvent. Data: ^3%s", "warn")
        end
        
        local currentTime = GetGameTimer()
        local tempAllowTime = player.getMeta("temp_allow_networkStartSyncScene", 0)
        
        if currentTime - tempAllowTime > 5000 then
            local blockUnauthorized = GetConvar("reaper_block_unauthorized_networked_scenes", "true")
            if blockUnauthorized == "true" then
                Logger.log("^3%s^7 (^3id:%s^7) just started a new networked scene event without authorization. Data: ^3%s", "warn")
                CancelEvent()
                return
            end
        end
    end)
    
    -- Update network synced scene event handler
    RPC.onLocal("updateNetworkSyncedSceneEvent", function(source, sceneData)
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        local logStart = GetConvar("reaper_log_start_networked_scene_events", "false")
        if logStart == "true" then
            Logger.log("^3%s^7 (^3id:%s^7) just emitted updateNetworkSyncedSceneEvent. Data: ^3%s", "warn")
        end
    end)
    
    -- Stop network synced scene event handler
    RPC.onLocal("stopNetworkSyncedSceneEvent", function(source, sceneData)
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        local logStart = GetConvar("reaper_log_start_networked_scene_events", "false")
        if logStart == "true" then
            Logger.log("^3%s^7 (^3id:%s^7) just emitted stopNetworkSyncedSceneEvent. Data: ^3%s", "warn")
        end
    end)
    
    -- Reaper network request control rejected handler
    RPC.onLocal("reaperNetworkRequestControlRejected", function(source, entityId)
        local player = Player(source)
        if not player then
            return
        end
        
        local logRejections = GetConvar("reaper_log_network_request_control_rejections", "true")
        if logRejections == "true" then
            player.NewLog("^3%s^7 (^3id:%s^7) attempted to request control of an entity but was rejected. Entity: ^3%s^7", "warn", "entities", {})
        end
        
        local banRejections = GetConvar("reaper_ban_network_request_control_rejections", "false")
        if banRejections == "true" then
            RPC.emitLocal("Reaper:NewDetection", {
                type = "REQUEST_CONTROL_EVENT",
                data = player.getMeta("REQUEST_CONTROL_EVENT", 0),
                params = {source},
                action = "Ban Player"
            }, player.getId())
        end
        
        local currentCount = player.getMeta("REQUEST_CONTROL_EVENT", 0)
        player.setMeta("REQUEST_CONTROL_EVENT", currentCount + 1)
        
        local currentCount = player.getMeta("REQUEST_CONTROL_EVENT", 0)
        local rateLimit = GetConvarInt("REAPER_REQUEST_CONTROL_EVENT_RATE", 25)
        if currentCount > rateLimit then
            RPC.emitLocal("Reaper:NewDetection", {
                type = "REQUEST_CONTROL_EVENT",
                data = player.getMeta("REQUEST_CONTROL_EVENT", 0),
                params = {source},
                action = "Ban Player"
            }, player.getId())
        end
        
        Wait(3000)
        local currentCount = player.getMeta("REQUEST_CONTROL_EVENT", 0)
        player.setMeta("REQUEST_CONTROL_EVENT", currentCount - 1)
    end)
    
    -- Ragdoll request event handler
    RPC.onLocal("ragdollRequestEvent", function(source, ragdollData)
        local logRagdoll = GetConvar("reaper_log_ragdoll_requests", "false")
        if logRagdoll == "true" then
            print("ragdollRequestEvent", source, json.encode(ragdollData))
        end
        CancelEvent()
    end)
    
    -- Set sync events logging
    Cache.set("logSyncEvents", false)
    
    -- REAPER sync event handler
    RPC.onLocal("REAPER_SYNC_EVENT", function(source, eventData, eventType)
        local logSync = Cache.get("logSyncEvents")
        if logSync then
            print("REAPER_SYNC_EVENT", source, eventData, eventType)
        end
    end)
    
    -- Request fire spawn handler
    RPC.register("requestFireSpawn", function(source, fireData)
        local player = Player(source)
        if not player then
            return "DENIED"
        end
        
        if fireData.type ~= "entity" and fireData.type ~= "script" then
            if not fireData.coords or type(fireData.coords) ~= "vector3" then
                return "DENIED"
            end
        end
        
        local allowedFires = player.getMeta("allowed_fires")
        if not allowedFires then
            allowedFires = {}
        end
        
        table.insert(allowedFires, {
            type = fireData.type,
            netId = fireData.netId,
            coords = fireData.coords,
            maxChildren = fireData.maxChildren
        })
        
        player.setMeta("allowed_fires", allowedFires)
        return "OK"
    end)
    
    -- Fire event handler
    RPC.onLocal("fireEvent", function(source, fireData)
        local fireInfo = fireData[1][1]
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        player.NewLog("^3%s^7 (^3id:%s^7) just created a new fire. Data: ^3%s^7", "info", "fire_events", {}, GetConvar("reaper_log_fireEvent", "false") ~= "true")
        
        if blockAllFireEvents then
            CancelEvent()
            return
        end
        
        if autoFireWhitelist then
            local allowedFires = player.getMeta("allowed_fires")
            if not allowedFires then
                allowedFires = {}
            end
            
            local isAllowed = false
            for _, allowedFire in pairs(allowedFires) do
                if allowedFire.type == "script" then
                    if fireInfo.weaponHash == 0 and fireInfo.entityGlobalId == 0 then
                        local distance = GetDistanceBetweenCoords(vec3(fireInfo.posX, fireInfo.posY, fireInfo.posZ), allowedFire.coords)
                        if distance < 20 then
                            isAllowed = true
                            break
                        end
                    end
                elseif allowedFire.type == "entity" then
                    if fireInfo.weaponHash == 0 and fireInfo.entityGlobalId ~= 0 then
                        isAllowed = true
                        break
                    end
                end
            end
            
            if not isAllowed then
                CancelEvent()
                return
            end
        end
    end)
    
    -- Clear ped tasks event handler
    RPC.onLocal("clearPedTasksEvent", function(...)
        CancelEvent()
        local logClearTasks = GetConvar("reaper_log_clearPedTasksEvent", "false")
        if logClearTasks == "true" then
            print(source, ...)
        end
    end)
    
    -- Vehicle component control event handler
    RPC.onLocal("vehicleComponentControlEvent", function(source, componentData)
        local player = Player(source)
        if not player then
            CancelEvent()
            return
        end
        
        local vehicle = NetworkGetEntityFromNetworkId(componentData.vehicleGlobalId)
        if vehicle == 0 then
            CancelEvent()
            return
        end
        
        local vehicleCoords = GetEntityCoords(vehicle)
        local logComponent = GetConvar("reaper_log_vehicleComponentControlEvent", "false")
        if logComponent == "true" then
            print("vehicleComponentControlEvent", json.encode({
                id = player.getId(),
                name = player.getName(),
                coords = player.getCoords()
            }), json.encode({
                vehicleGlobalId = componentData.vehicleGlobalId,
                coords = vehicleCoords
            }), json.encode(componentData))
        end
        
        if componentData.componentIndex == 0 or componentData.componentIndex == 4 then
            local distance = GetDistanceBetweenCoords(vehicleCoords, player.getCoords(), true)
            if distance > 10 then
                local filterComponent = GetConvar("reaper_filter_vehicleComponentControlEvent", "true")
                if filterComponent == "true" then
                    CancelEvent()
                end
            end
        end
    end)
    
    -- Vehicle component control reply handler
    RPC.onLocal("vehicleComponentControlReply", function(source, replyData)
        local logComponent = GetConvar("reaper_log_vehicleComponentControlEvent", "false")
        if logComponent == "true" then
            print("vehicleComponentControlReply", source, json.encode(replyData))
        end
    end)
    
    -- IsEntityPlayingAnim handler
    RPC.register("IsEntityPlayingAnim", function(source, targetPlayer, animDict, animName, taskFlag)
        local sourcePlayer = Player(source)
        local targetPlayerObj = Player(targetPlayer)
        if not sourcePlayer or not targetPlayerObj then
            return false
        end
        
        local result = RPC.await("IsEntityPlayingAnim", targetPlayer, {
            animDict,
            animName,
            taskFlag
        }, 1000, 4000)
        
        if result == "RESPONSE_FAILED" then
            return false
        end
        
        return result
    end)
    
    -- Set replicated cache value handler
    RPC.register("SetReplicatedCacheValue", function(source, key, value)
        local player = Player(source)
        if not player then
            return true
        end
        
        player.setMeta("replicated_" .. key, value)
        return true
    end)
end)

-- Get OneSync data function
function getOneSyncData(playerId)
    local data = RPC.await("getOneSyncData", playerId)
    local result = {}
    
    result.in_vehicle = data["45e82eb1e9d079258ae0"]
    result.has_parachute = data["20b5e2be3d793c8a337cccf118"]
    result.renderingCam = data["92b1f557ade2a7a71f86b495"]
    result.isEntityVisible = data["4523c489bea7323571ee0dd82e1161"]
    result.alpha_level = data["1d6a876bc5e3efa9eedb10"]
    result.last_known_cam_change = data["b4b5e2a704c1a0ec65a30d297f221f782ecf518278"]
    result.last_known_invisible_change = data["b4b5e2a704c1a0ec65a30d43f86b4da3a3e3d93798e7cd307186f9"]
    result.last_known_alpha_change = data["b4b5e2a704c1a0ec65a30dcbbee562017e275c85b95f35"]
    result.ped_model = data["48b11bbe9668b09444"]
    result.network_is_in_spectator_mode = data["feb1abbc73934dde6e37960a76828691914e17b623bed22211a0e396"]
    
    return result
end

-- OneSync monitoring thread
CreateThread(function()
    while true do
        if antiNativeSpoofer then
            local players = GetPlayers()
            for _, playerId in pairs(players) do
                local player = Player(playerId)
                if player then
                    local ped = player.getPed()
                    if ped ~= 0 then
                        local checkPedModel = GetConvar("reaper_check_ped_model_server", "false")
                        if checkPedModel == "true" then
                            local replicatedModel = player.getMeta("replicated_" .. player.getPedModel())
                            if not replicatedModel then
                                local oneSyncData = getOneSyncData(player.getId())
                                if oneSyncData ~= "RESPONSE_FAILED" then
                                    if oneSyncData.ped_model ~= player.getPedModel() then
                                        RPC.emitLocal("Reaper:NewDetection", {
                                            type = "NATIVE_SPOOF",
                                            data = oneSyncData,
                                            params = {"GetEntityModel()"},
                                            action = "Ban Player"
                                        }, player.getId())
                                    end
                                end
                            end
                        end
                        
                        local isInFreeCam = player.isInFreeCam()
                        local freeCamStatus = player.getMeta("free_cam_status", false)
                        if isInFreeCam ~= freeCamStatus then
                            if isInFreeCam then
                                CreateThread(function()
                                    local oneSyncData = getOneSyncData(player.getId())
                                    if oneSyncData ~= "RESPONSE_FAILED" then
                                        if player.isInFreeCam() then
                                            if oneSyncData.renderingCam == -1 then
                                                if not oneSyncData.in_vehicle then
                                                    if not oneSyncData.has_parachute then
                                                        if oneSyncData.last_known_cam_change > 20000 then
                                                            if not oneSyncData.network_is_in_spectator_mode then
                                                                RPC.emitLocal("Reaper:NewDetection", {
                                                                    type = "NATIVE_SPOOF",
                                                                    data = oneSyncData,
                                                                    params = {"GetRenderingCam()"},
                                                                    action = "Ban Player"
                                                                }, player.getId())
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                            player.setMeta("free_cam_status", isInFreeCam, 10)
                        end
                        
                        local isVisible = player.isVisible()
                        local visibleStatus = player.getMeta("visible_status", false)
                        if isVisible ~= visibleStatus then
                            if not isVisible then
                                CreateThread(function()
                                    local oneSyncData = getOneSyncData(player.getId())
                                    if oneSyncData ~= "RESPONSE_FAILED" then
                                        if not player.isVisible() then
                                            if oneSyncData.renderingCam == -1 then
                                                if oneSyncData.isEntityVisible then
                                                    if oneSyncData.last_known_invisible_change > 20000 then
                                                        RPC.emitLocal("Reaper:NewDetection", {
                                                            type = "NATIVE_SPOOF",
                                                            data = oneSyncData,
                                                            params = {"IsEntityVisible()"},
                                                            action = "Ban Player"
                                                        }, player.getId())
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                            player.setMeta("visible_status", isVisible, 10)
                        end
                    end
                end
                Wait(25)
            end
            local playerCount = #players
            local waitTime = 1000 / playerCount
            Wait(waitTime)
        else
            Wait(10000)
        end
        Wait(0)
    end
end)