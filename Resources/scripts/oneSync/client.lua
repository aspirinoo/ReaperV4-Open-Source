-- Reaper AntiCheat - Client OneSync System
-- Cleaned and deobfuscated version

local Security = Security
local Logger = Logger
local RPC = RPC
local Player = Player
local NUI = NUI
local IsEntityPlayingAnim = IsEntityPlayingAnim
local PlayerPedId = PlayerPedId
local GetRenderingCam = GetRenderingCam
local IsEntityVisible = IsEntityVisible
local GetEntityAlpha = GetEntityAlpha
local GetGameTimer = GetGameTimer
local IsPedInAnyVehicle = IsPedInAnyVehicle
local GetPedParachuteState = GetPedParachuteState
local GetEntityModel = GetEntityModel
local GetVehiclePedIsEntering = GetVehiclePedIsEntering

-- Helper function to convert values to boolean
local function toBoolean(value)
    if value == 1 or value == true then
        return true
    else
        return false
    end
end

-- Register IsEntityPlayingAnim RPC
RPC.register("IsEntityPlayingAnim", function(entity, animDict, animName, taskFlag)
    return IsEntityPlayingAnim(PlayerPedId(), entity, animDict, taskFlag)
end)

-- Register getOneSyncData RPC
RPC.register("getOneSyncData", function()
    local currentTime = GetGameTimer()
    local playerPed = PlayerPedId()
    local data = {}
    
    -- Check if player is in vehicle
    local inVehicle = toBoolean(IsPedInAnyVehicle(playerPed, true))
    if not inVehicle then
        local enteringVehicle = Player.get("enteringVehicle", 0)
        inVehicle = currentTime - enteringVehicle < 5000
    end
    data["45e82eb1e9d079258ae0"] = inVehicle
    
    -- Check parachute state
    local parachuteState = GetPedParachuteState(playerPed)
    data["20b5e2be3d793c8a337cccf118"] = parachuteState ~= -1
    
    -- Get rendering camera
    local renderingCam = GetRenderingCam()
    data["92b1f557ade2a7a71f86b495"] = renderingCam
    
    -- Check entity visibility
    local isVisible = toBoolean(IsEntityVisible(playerPed))
    data["4523c489bea7323571ee0dd82e1161"] = isVisible
    
    -- Get entity alpha
    local alpha = GetEntityAlpha(playerPed)
    data["1d6a876bc5e3efa9eedb10"] = alpha
    
    -- Get camera change time
    local camChangeTime = Player.get("CamChange", 0)
    data["b4b5e2a704c1a0ec65a30d297f221f782ecf518278"] = currentTime - camChangeTime
    
    -- Get entity visible change time
    local entityVisibleTime = Player.getSetTime("EntityVisible")
    data["b4b5e2a704c1a0ec65a30d43f86b4da3a3e3d93798e7cd307186f9"] = currentTime - entityVisibleTime
    
    -- Get alpha change time
    local alphaChangeTime = Player.getSetTime("alphaSetTo0")
    data["b4b5e2a704c1a0ec65a30dcbbee562017e275c85b95f35"] = currentTime - alphaChangeTime
    
    -- Get entity model
    local entityModel = GetEntityModel(playerPed)
    data["48b11bbe9668b09444"] = entityModel
    
    -- Check network spectator mode
    local networkSpectator = Player.get("NetworkIsInSpectatorMode", false)
    if not networkSpectator then
        networkSpectator = Player.getRecentlyChanged("NetworkIsInSpectatorMode", 10000)
    end
    data["feb1abbc73934dde6e37960a76828691914e17b623bed22211a0e396"] = networkSpectator
    
    return data
end)