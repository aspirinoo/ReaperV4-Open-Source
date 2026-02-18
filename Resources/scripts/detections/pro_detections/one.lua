-- Reaper AntiCheat - Pro Detection System
-- Cleaned and deobfuscated version

local Security = Security
local Logger = Logger
local RPC = RPC
local Player = Player
local IsAimCamActive = IsAimCamActive
local CreateThread = CreateThread
local IsControlJustPressed = IsControlJustPressed
local Wait = Wait
local GetFinalRenderedCamRot = GetFinalRenderedCamRot
local GetGameTimer = GetGameTimer
local GetSelectedPedWeapon = GetSelectedPedWeapon
local IsPedInMeleeCombat = IsPedInMeleeCombat
local IsPauseMenuActive = IsPauseMenuActive
local IsPedDeadOrDying = IsPedDeadOrDying
local IsPedAimingFromCover = IsPedAimingFromCover
local IsPedInCover = IsPedInCover
local IsPedGoingIntoCover = IsPedGoingIntoCover
local IsPedInAnyVehicle = IsPedInAnyVehicle
local IsGameplayCamShaking = IsGameplayCamShaking
local IsCinematicIdleCamRendering = IsCinematicIdleCamRendering
local GetFinalRenderedCamMotionBlurStrength = GetFinalRenderedCamMotionBlurStrength
local IsCinematicCamRendering = IsCinematicCamRendering
local GetFollowPedCamViewMode = GetFollowPedCamViewMode
local GetFrameTime = GetFrameTime
local IsNuiFocused = IsNuiFocused
local IsUsingKeyboard = IsUsingKeyboard
local DisableControlAction = DisableControlAction
local IsControlEnabled = IsControlEnabled
local GetHashKey = GetHashKey
local PlayerPedId = PlayerPedId
local math = math
local table = table
local tostring = tostring

-- Anti-Aimbot detection variables
local aimbotFlags = 0
local aimbotData = {}
local lastWeaponChange = 0
local lastCombatTime = 0
local lastWeapon = nil
local isEnabled = false

-- Configuration handlers
RPC.on("reaperReady", function()
    local config = Player.get("config")
    local configHash = tostring(Security.hash("antiAimBot"))
    isEnabled = config[configHash]
end)

RPC.on("configUpdated", function()
    local config = Player.get("config")
    local configHash = tostring(Security.hash("antiAimBot"))
    isEnabled = config[configHash]
end)

-- Main detection thread
CreateThread(function()
    while true do
        Wait(0)
        if isEnabled then
            if IsAimCamActive() then
                if IsControlJustPressed(0, 25) then
                    if aimbotFlags == 0 then
                        lastWeaponChange = GetGameTimer()
                    end
                end
            else
                aimbotFlags = 0
            end
        else
            Wait(10000)
        end
    end
end)

-- Get camera rotation
local function getCameraRotation()
    local rotation = GetFinalRenderedCamRot()
    return rotation.z
end

-- Main aimbot detection thread
CreateThread(function()
    while true do
        if isEnabled then
            Wait(250)
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)
            local currentTime = GetGameTimer()
            
            if lastWeapon ~= weapon then
                lastWeaponChange = currentTime
                lastWeapon = weapon
            end
            
            if IsPedInMeleeCombat(ped) then
                lastCombatTime = currentTime
            end
            
            local timeSinceLastChange = currentTime - lastWeaponChange
            if timeSinceLastChange < 200 then
                if lastWeaponChange == 0 then
                    goto continue
                end
            end
            
            local timeSinceCombat = currentTime - lastCombatTime
            if timeSinceCombat < 1000 then
                if timeSinceCombat < 1000 then
                    goto continue
                end
            end
            
            aimbotData = {}
            goto continue
            
            ::continue::
            
            if GetHashKey("WEAPON_UNARMED") == weapon then
                aimbotData = {}
            else
                if IsPauseMenuActive() or IsNuiFocused() or IsPedDeadOrDying(ped) or IsPedAimingFromCover(ped) or IsPedInCover(ped, false) or IsPedGoingIntoCover(ped, true) then
                    aimbotData = {}
                    goto continue
                end
                
                if IsGameplayCamShaking() or IsCinematicIdleCamRendering() or IsPedInAnyVehicle(ped) or IsCinematicCamRendering() or GetFollowPedCamViewMode() ~= 4 or GetFinalRenderedCamMotionBlurStrength() <= 1.0E-4 or GetFrameTime() <= 0.02 then
                    if IsUsingKeyboard(0) then
                        DisableControlAction(0, 1, true)
                        DisableControlAction(0, 2, true)
                        local cameraRotation = getCameraRotation()
                        Wait(0)
                        
                        if IsControlEnabled(0, 1) or IsControlEnabled(0, 2) then
                            local rotationChange = math.abs(cameraRotation - getCameraRotation())
                            if IsAimCamActive() then
                                if rotationChange > 0.01 then
                                    table.insert(aimbotData, rotationChange)
                                end
                            else
                                aimbotData = {}
                            end
                            
                            if #aimbotData > 2 then
                                CreateThread(function()
                                    local config = Player.get("config")
                                    local maxFlags = config[tostring(Security.hash("max_aimbot_flags"))]
                                    local currentFlags = Player.get("aimbot_flags", 0) + 1
                                    
                                    Player.set("aimbot_flags", currentFlags)
                                    
                                    if maxFlags <= currentFlags then
                                        Player.newDetection("antiAimBot", nil, {}, {})
                                        Player.set("aimbot_flags", 0)
                                    end
                                    
                                    Wait(6000)
                                    local flags = Player.get("aimbot_flags", 0)
                                    if flags >= 0 then
                                        Player.set("aimbot_flags", flags - 1)
                                    end
                                end)
                                aimbotData = {}
                            end
                        end
                    end
                end
            end
        else
            Wait(10000)
        end
    end
end)