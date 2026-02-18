-- ReaperV4 Tests Script
-- Clean and optimized version
-- This file contains test commands for debugging

local Security = Security
local Logger = Logger
local RPC = RPC
local Player = Player
local NUI = NUI
local GetConvar = GetConvar

local gameType = GetConvar("reaper_gameType", "unknown")

-- Test commands are loaded when reaper_test_server is set to true
Logger.log(Logger, "Test commands loaded", "debug")
print("Loaded test commands")

-- Test command: Fast run
RegisterCommand("fastrun", function()
    CreateThread(function()
        while true do
            Wait(1)
            SetPedMoveRateOverride(PlayerPedId(), 10.0)
        end
    end)
end, false)

-- Test command: Super jump
RegisterCommand("superjump", function()
    CreateThread(function()
        while true do
            Wait(1)
            SetSuperJumpThisFrame(PlayerId())
        end
    end)
end, false)

-- Test command: Noclip
local noclip = false
RegisterCommand("noclip", function()
    noclip = not noclip
    local ped = PlayerPedId()
    
    CreateThread(function()
        while noclip do
            Wait(0)
            SetEntityInvincible(ped, true)
            SetEntityCollision(ped, false, false)
            
            local x, y, z = table.unpack(GetEntityCoords(ped))
            local dx, dy, dz = GetCamDirection()
            local speed = 2.0
            
            if IsControlPressed(0, 32) then -- W
                x = x + dx * speed
                y = y + dy * speed
                z = z + dz * speed
            end
            
            if IsControlPressed(0, 33) then -- S
                x = x - dx * speed
                y = y - dy * speed
                z = z - dz * speed
            end
            
            SetEntityCoords(ped, x, y, z, false, false, false, false)
        end
        
        SetEntityInvincible(ped, false)
        SetEntityCollision(ped, true, true)
    end)
end, false)

-- Test command: Godmode
local godmode = false
RegisterCommand("god", function()
    godmode = not godmode
    local ped = PlayerPedId()
    
    CreateThread(function()
        while godmode do
            Wait(0)
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
        end
        
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)
    end)
end, false)

-- Test command: Teleport to waypoint
RegisterCommand("tpwaypoint", function()
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        local coords = GetBlipCoords(waypoint)
        local ped = PlayerPedId()
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    end
end, false)

-- Test command: Spawn vehicle
RegisterCommand("spawnveh", function(source, args)
    if #args > 0 then
        local model = args[1]
        local hash = GetHashKey(model)
        
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
        
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
        
        SetPedIntoVehicle(ped, vehicle, -1)
        SetModelAsNoLongerNeeded(hash)
    end
end, false)

-- Test command: Fix vehicle
RegisterCommand("fixveh", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, false)
    end
end, false)

-- Test command: Delete vehicle
RegisterCommand("delveh", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        DeleteVehicle(vehicle)
    end
end, false)

-- Helper function to get camera direction
function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end

print("Test commands initialized")
