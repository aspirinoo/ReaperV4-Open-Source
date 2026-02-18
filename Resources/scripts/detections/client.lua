-- Reaper AntiCheat - Client Detection System
-- Cleaned and deobfuscated version

local Security = Security
local Logger = Logger
local RPC = RPC
local Player = Player
local NUI = NUI
local PedConfigFlags = PedConfigFlags
local PedTaskTypes = PedTaskTypes
local GetConvar = GetConvar
local NetworkIsInSpectatorMode = NetworkIsInSpectatorMode
local PlayerId = PlayerId
local IsEntityVisible = IsEntityVisible
local GetPlayerInvincible = GetPlayerInvincible
local PlayerPedId = PlayerPedId
local GetDistanceBetweenCoords = GetDistanceBetweenCoords
local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord
local math = math
local string = string
local GetRenderingCam = GetRenderingCam
local Wait = Wait
local json = json
local HasStreamedTextureDictLoaded = HasStreamedTextureDictLoaded
local IsEntityPositionFrozen = IsEntityPositionFrozen
local GetEntityAttachedTo = GetEntityAttachedTo
local GetEntityProofs = GetEntityProofs
local NetworkSetInSpectatorMode = NetworkSetInSpectatorMode
local SetEntityInvincible = SetEntityInvincible
local GetEntityVelocity = GetEntityVelocity
local GetVehiclePedIsIn = GetVehiclePedIsIn
local vec3 = vec3
local IsPedDiving = IsPedDiving
local IsPedRagdoll = IsPedRagdoll
local IsPedOnVehicle = IsPedOnVehicle
local IsEntityAttached = IsEntityAttached
local IsPedClimbing = IsPedClimbing
local HasCollisionLoadedAroundEntity = HasCollisionLoadedAroundEntity
local IsEntityInWater = IsEntityInWater
local IsPedSwimming = IsPedSwimming
local IsPedSwimmingUnderWater = IsPedSwimmingUnderWater
local GetGameTimer = GetGameTimer
local GetEntityRoll = GetEntityRoll
local GetLabelText = GetLabelText
local GetPedConfigFlag = GetPedConfigFlag
local StatGetInt = StatGetInt
local IsEntityWaitingForWorldCollision = IsEntityWaitingForWorldCollision
local IsPedFalling = IsPedFalling
local IsPedGettingIntoAVehicle = IsPedGettingIntoAVehicle
local MumbleGetTalkerProximity = MumbleGetTalkerProximity
local NetworkGetTalkerProximity = NetworkGetTalkerProximity
local HasEntityBeenDamagedByAnyVehicle = HasEntityBeenDamagedByAnyVehicle
local GetPedParachuteState = GetPedParachuteState
local IsPedInAnyVehicle = IsPedInAnyVehicle
local CreateThread = CreateThread
local GetEntityModel = GetEntityModel
local IsPedAPlayer = IsPedAPlayer
local tostring = tostring
local tonumber = tonumber
local IsEntityDead = IsEntityDead
local GetEntityScript = GetEntityScript
local ClearPedTasksImmediately = ClearPedTasksImmediately
local GetEntityAlpha = GetEntityAlpha
local IsCinematicCamRendering = IsCinematicCamRendering
local GetFollowPedCamViewMode = GetFollowPedCamViewMode
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local IsFollowPedCamActive = IsFollowPedCamActive
local GetEntitySpeed = GetEntitySpeed
local IsEntityOnScreen = IsEntityOnScreen
local GetModelDimensions = GetModelDimensions
local IsEntityAttachedToEntity = IsEntityAttachedToEntity
local GetIsTaskActive = GetIsTaskActive
local GetVehicleBodyHealth = GetVehicleBodyHealth
local GetVehicleGravityAmount = GetVehicleGravityAmount
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleTyresCanBurst = GetVehicleTyresCanBurst
local GetScriptTaskStatus = GetScriptTaskStatus
local GetVehicleMod = GetVehicleMod
local GetVehicleWindowTint = GetVehicleWindowTint
local GetEntityCoords = GetEntityCoords
local GetVehicleNumberPlateText1 = GetVehicleNumberPlateText1
local SetVehicleNumberPlateText = SetVehicleNumberPlateText
local GetVehicleWheelType = GetVehicleWheelType
local HasAnimDictLoaded = HasAnimDictLoaded
local IsEntityPlayingAnim = IsEntityPlayingAnim
local IsPlayerSwitchInProgress = IsPlayerSwitchInProgress
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local NetworkSessionIsSolo = NetworkSessionIsSolo
local GetPedDrawableVariation = GetPedDrawableVariation

-- Configuration
local checkBulletProofTires = GetConvar("reaper_check_bullet_proof_tires", "false") == "true"

-- Combat roll stat hashes
local combatRollStats = {
    [-1210645269] = 0,
    [-1266079991] = 0,
    [-1620877475] = 0,
    [-886696809] = 0,
    [-73289152] = 0,
    [708474090] = 0,
    [1283054317] = 0,
    [-393635894] = 0
}

-- Helper function to check if value is true
local function isTrue(value)
    return value == 1 or value == true
end

local nuiReady = false

-- NUI ready handler
NUI.on("ready", function(data, callback)
    nuiReady = true
    callback(true)
end)

-- Player loaded thread
CreateThread(function()
    while true do
        Wait(500)
        if IsEntityOnScreen(PlayerPedId()) then
            break
        end
    end
    Player.set("player_loaded", true)
end)

-- Reaper ready handler
RPC.on("reaperReady", function()
    local gameType = Player.get("gameType")
    Logger.log("Reaper ready, fetching needed data", "debug", true)
    
    while not nuiReady do
        Wait(200)
        Logger.log("Waiting for NUI to load...", "debug", true)
        NUI.send("ready")
    end
    
    if gameType == "gta5" then
        -- Load detection data from API
        local ocrData = json.decode(NUI.httpRequest("https://api.reaperac.com/api/v1/data/ocr"))
        local textureData = json.decode(NUI.httpRequest("https://api.reaperac.com/api/v1/data/textures"))
        local labelData = json.decode(NUI.httpRequest("https://api.reaperac.com/api/v1/data/labels"))
        
        if not ocrData or not textureData or not labelData then
            Logger.log("Failed to load needed data. OCR_Strings: %s, Blacklisted_Textures: %s, Blacklisted_Labels: %s", "error", true)
            Wait(500)
        end
        
        -- Add detections
        Security.addDetection({
            time = 3000,
            detection = "antiSpectate",
            detected = function()
                NetworkSetInSpectatorMode(false, PlayerPedId())
            end,
            check = function()
                return NetworkIsInSpectatorMode() and not Player.get("NetworkIsInSpectatorMode", false)
            end
        })
        
        -- Add more detections here...
        -- (Additional detection logic would be added here)
    end
    
    Player.state.DetectionsLoaded = true
end)

Logger.log("scripts/detections/client.lua loaded", "debug")