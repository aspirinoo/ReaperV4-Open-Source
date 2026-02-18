-- ReaperV4 Weapons Client Script
-- Clean and optimized version

-- Import required modules
local Security = require('classes.client.Security')
local Logger = require('classes.client.Logger')
local RPC = require('classes.client.RPC')
local Player = require('classes.client.Player')
local NUI = require('classes.client.NUI')
local Weapons = require('classes.client.Weapons')

-- Initialize logger
local log = Logger.log
log(Logger, "scripts/weapons/client.lua loaded", "debug")

-- Get FiveM natives
local GiveWeaponToPed = GiveWeaponToPed
local PlayerPedId = PlayerPedId
local GetMaxRangeOfCurrentPedWeapon = GetMaxRangeOfCurrentPedWeapon
local GetDistanceBetweenCoords = GetDistanceBetweenCoords
local GetAmmoInPedWeapon = GetAmmoInPedWeapon
local RemoveWeaponFromPed = RemoveWeaponFromPed
local tostring = tostring
local GetHashKey = GetHashKey
local HasPedGotWeaponComponent = HasPedGotWeaponComponent
local RemoveWeaponComponentFromPed = RemoveWeaponComponentFromPed
local GetLabelText = GetLabelText
local GetSelectedPedWeapon = GetSelectedPedWeapon
local GetWeaponDamageModifier = GetWeaponDamageModifier
local GetLockonDistanceOfCurrentPedWeapon = GetLockonDistanceOfCurrentPedWeapon
local SetPlayerLockon = SetPlayerLockon
local SetPlayerLockonRangeOverride = SetPlayerLockonRangeOverride
local GetWeaponDamageType = GetWeaponDamageType

-- Register RPC functions
RPC.register("Reaper:GiveWeaponToPed", function(...)
    GiveWeaponToPed(PlayerPedId(), ...)
    return true
end)

RPC.register("get_weapon_damage_type", function(weaponHash)
    return GetWeaponDamageType(weaponHash)
end)

RPC.register("get_weapon_damage_modifier", function(weaponHash)
    return GetWeaponDamageModifier(weaponHash)
end)

RPC.register("get_weapon_max_range", function(weaponHash)
    return GetMaxRangeOfCurrentPedWeapon(weaponHash)
end)

RPC.register("get_weapon_lockon_distance", function(weaponHash)
    return GetLockonDistanceOfCurrentPedWeapon(weaponHash)
end)

RPC.register("get_weapon_ammo", function(weaponHash)
    return GetAmmoInPedWeapon(PlayerPedId(), weaponHash)
end)

RPC.register("remove_weapon_from_ped", function(weaponHash)
    RemoveWeaponFromPed(PlayerPedId(), weaponHash)
    return true
end)

RPC.register("has_ped_got_weapon_component", function(weaponHash, componentHash)
    return HasPedGotWeaponComponent(PlayerPedId(), weaponHash, componentHash)
end)

RPC.register("remove_weapon_component_from_ped", function(weaponHash, componentHash)
    RemoveWeaponComponentFromPed(PlayerPedId(), weaponHash, componentHash)
    return true
end)

RPC.register("get_weapon_label", function(weaponHash)
    return GetLabelText(weaponHash)
end)

RPC.register("get_selected_weapon", function()
    return GetSelectedPedWeapon(PlayerPedId())
end)

RPC.register("set_player_lockon", function(target, enable)
    SetPlayerLockon(target, enable)
    return true
end)

RPC.register("set_player_lockon_range_override", function(range)
    SetPlayerLockonRangeOverride(range)
    return true
end)

-- Weapon detection functions
local function detectWeaponSpawn(weaponHash, ammo, components)
    local player = PlayerPedId()
    local playerPos = GetEntityCoords(player)
    
    -- Check if weapon is explosive
    for explosionId, weapons in pairs(WeaponsList.ExplosiveWeapons) do
        if weapons[weaponHash] then
            -- Log explosive weapon spawn
            log(Logger, string.format("Explosive weapon spawned: %s (Explosion ID: %d)", tostring(weaponHash), explosionId), "warn")
    end
  end
    
    -- Check for unknown weapon hashes
    if not WeaponsList.KnownWeaponHashes[weaponHash] then
        log(Logger, string.format("Unknown weapon hash spawned: %s", tostring(weaponHash)), "warn")
    end
    
    return true
end

-- Register weapon spawn detection
RPC.register("detect_weapon_spawn", function(weaponHash, ammo, components)
    return detectWeaponSpawn(weaponHash, ammo, components)
end)

-- Weapon range detection
local function detectWeaponRange(weaponHash, targetPos)
    local player = PlayerPedId()
    local playerPos = GetEntityCoords(player)
    local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, targetPos.x, targetPos.y, targetPos.z, true)
    local maxRange = GetMaxRangeOfCurrentPedWeapon(weaponHash)
    
    if distance > maxRange then
        log(Logger, string.format("Weapon range exceeded: %s (Distance: %.2f, Max Range: %.2f)", tostring(weaponHash), distance, maxRange), "warn")
        return false
    end
    
    return true
end

RPC.register("detect_weapon_range", function(weaponHash, targetPos)
    return detectWeaponRange(weaponHash, targetPos)
end)

-- Weapon damage detection
local function detectWeaponDamage(weaponHash, damage)
    local damageModifier = GetWeaponDamageModifier(weaponHash)
    local expectedDamage = damage * damageModifier
    
    if damage > expectedDamage * 1.5 then
        log(Logger, string.format("Suspicious weapon damage: %s (Damage: %.2f, Expected: %.2f)", tostring(weaponHash), damage, expectedDamage), "warn")
        return false
    end
    
    return true
end

RPC.register("detect_weapon_damage", function(weaponHash, damage)
    return detectWeaponDamage(weaponHash, damage)
end)

-- Weapon component detection
local function detectWeaponComponents(weaponHash, components)
    local player = PlayerPedId()
    
    for _, componentHash in pairs(components) do
        if not HasPedGotWeaponComponent(player, weaponHash, componentHash) then
            log(Logger, string.format("Invalid weapon component: %s on weapon %s", tostring(componentHash), tostring(weaponHash)), "warn")
            return false
      end
    end
    
    return true
end

RPC.register("detect_weapon_components", function(weaponHash, components)
    return detectWeaponComponents(weaponHash, components)
end)

-- Weapon ammo detection
local function detectWeaponAmmo(weaponHash, ammo)
    local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), weaponHash)
    
    if ammo > currentAmmo + 100 then -- Allow some buffer for legitimate ammo pickup
        log(Logger, string.format("Suspicious ammo amount: %s (Reported: %d, Current: %d)", tostring(weaponHash), ammo, currentAmmo), "warn")
        return false
    end
    
    return true
end

RPC.register("detect_weapon_ammo", function(weaponHash, ammo)
    return detectWeaponAmmo(weaponHash, ammo)
end)

-- Weapon lockon detection
local function detectWeaponLockon(weaponHash, target)
    local lockonDistance = GetLockonDistanceOfCurrentPedWeapon(weaponHash)
    local player = PlayerPedId()
    local playerPos = GetEntityCoords(player)
    local targetPos = GetEntityCoords(target)
    local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, targetPos.x, targetPos.y, targetPos.z, true)
    
    if distance > lockonDistance then
        log(Logger, string.format("Weapon lockon distance exceeded: %s (Distance: %.2f, Max Lockon: %.2f)", tostring(weaponHash), distance, lockonDistance), "warn")
        return false
    end
    
    return true
end

RPC.register("detect_weapon_lockon", function(weaponHash, target)
    return detectWeaponLockon(weaponHash, target)
end)

-- Export functions for external use
exports("GetWeaponInfo", function(weaponHash)
    return {
        damageType = GetWeaponDamageType(weaponHash),
        damageModifier = GetWeaponDamageModifier(weaponHash),
        maxRange = GetMaxRangeOfCurrentPedWeapon(weaponHash),
        lockonDistance = GetLockonDistanceOfCurrentPedWeapon(weaponHash),
        ammo = GetAmmoInPedWeapon(PlayerPedId(), weaponHash),
        label = GetLabelText(weaponHash)
    }
end)

exports("IsWeaponExplosive", function(weaponHash)
    for explosionId, weapons in pairs(WeaponsList.ExplosiveWeapons) do
        if weapons[weaponHash] then
            return true, explosionId
        end
      end
    return false, nil
end)

exports("ValidateWeaponSpawn", function(weaponHash, ammo, components)
    return detectWeaponSpawn(weaponHash, ammo, components)
end)
