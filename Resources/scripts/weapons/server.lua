-- ReaperV4 Weapons Server Script
-- Clean and optimized version

-- Import required modules
local Logger = require('classes.server.Logger')
local RPC = require('classes.server.RPC')
local Player = require('classes.server.Player')
local Security = require('classes.server.Security')
local Weapons = require('classes.server.Weapons')

-- Initialize logger
local log = Logger.log
log(Logger, "scripts/weapons/server.lua loaded", "debug")

-- Weapon detection and monitoring
local weaponDetections = {}
local weaponStats = {}

-- Register RPC functions for weapon monitoring
RPC.register("Reaper:WeaponDetection", function(source, weaponHash, detectionType, data)
    local player = Player(source)
    if not player then
        return false
    end
    
    -- Log weapon detection
    log(Logger, string.format("Weapon detection: %s - %s (Player: %s)", tostring(weaponHash), detectionType, player.getName()), "warn")
    
    -- Store detection
    if not weaponDetections[source] then
        weaponDetections[source] = {}
    end
    
    table.insert(weaponDetections[source], {
        weaponHash = weaponHash,
        detectionType = detectionType,
        data = data,
        timestamp = os.time()
    })
    
    -- Update statistics
    if not weaponStats[weaponHash] then
        weaponStats[weaponHash] = {
            detections = 0,
            players = {}
        }
    end
    
    weaponStats[weaponHash].detections = weaponStats[weaponHash].detections + 1
    weaponStats[weaponHash].players[source] = true
    
    return true
end)

-- Weapon spawn validation
RPC.register("Reaper:ValidateWeaponSpawn", function(source, weaponHash, ammo, components)
    local player = Player(source)
    if not player then
        return false
    end
    
    -- Check if weapon is in explosive weapons list
    for explosionId, weapons in pairs(WeaponsList.ExplosiveWeapons) do
        if weapons[weaponHash] then
            log(Logger, string.format("Explosive weapon spawn attempt: %s (Player: %s)", tostring(weaponHash), player.getName()), "warn")
            
            -- Trigger detection
            RPC.emitLocal("Reaper:WeaponDetection", source, weaponHash, "explosive_spawn", {
                explosionId = explosionId,
                ammo = ammo,
                components = components
            })
            
            return false
        end
    end
    
    -- Check for unknown weapon hashes
    if not WeaponsList.KnownWeaponHashes[weaponHash] then
        log(Logger, string.format("Unknown weapon hash spawn attempt: %s (Player: %s)", tostring(weaponHash), player.getName()), "warn")
        
        -- Trigger detection
        RPC.emitLocal("Reaper:WeaponDetection", source, weaponHash, "unknown_weapon", {
            ammo = ammo,
            components = components
        })
        
        return false
    end
    
    return true
end)

-- Weapon damage validation
RPC.register("Reaper:ValidateWeaponDamage", function(source, weaponHash, damage, target)
    local player = Player(source)
    if not player then
        return false
    end
    
    -- Get weapon damage modifier
    local damageModifier = GetWeaponDamageModifier(weaponHash)
    local expectedDamage = damage * damageModifier
    
    -- Check for suspicious damage
    if damage > expectedDamage * 1.5 then
        log(Logger, string.format("Suspicious weapon damage: %s - %.2f (Expected: %.2f) (Player: %s)", 
            tostring(weaponHash), damage, expectedDamage, player.getName()), "warn")
        
        -- Trigger detection
        RPC.emitLocal("Reaper:WeaponDetection", source, weaponHash, "damage_modification", {
            damage = damage,
            expectedDamage = expectedDamage,
            target = target
        })
        
        return false
    end
    
    return true
end)

-- Weapon range validation
RPC.register("Reaper:ValidateWeaponRange", function(source, weaponHash, targetPos)
    local player = Player(source)
    if not player then
        return false
    end
    
    -- Get player position
    local playerPos = GetEntityCoords(GetPlayerPed(source))
    local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, 
        targetPos.x, targetPos.y, targetPos.z, true)
    
    -- Get weapon max range
    local maxRange = GetMaxRangeOfCurrentPedWeapon(weaponHash)
    
    -- Check if range is exceeded
    if distance > maxRange then
        log(Logger, string.format("Weapon range exceeded: %s - Distance: %.2f, Max Range: %.2f (Player: %s)", 
            tostring(weaponHash), distance, maxRange, player.getName()), "warn")
        
        -- Trigger detection
        RPC.emitLocal("Reaper:WeaponDetection", source, weaponHash, "range_exceeded", {
            distance = distance,
            maxRange = maxRange,
            targetPos = targetPos
        })
        
        return false
    end
    
    return true
end)

-- Weapon ammo validation
RPC.register("Reaper:ValidateWeaponAmmo", function(source, weaponHash, ammo)
    local player = Player(source)
    if not player then
        return false
    end
    
    -- Get current ammo
    local currentAmmo = GetAmmoInPedWeapon(GetPlayerPed(source), weaponHash)
    
    -- Check for suspicious ammo amounts
    if ammo > currentAmmo + 100 then
        log(Logger, string.format("Suspicious ammo amount: %s - Reported: %d, Current: %d (Player: %s)", 
            tostring(weaponHash), ammo, currentAmmo, player.getName()), "warn")
        
        -- Trigger detection
        RPC.emitLocal("Reaper:WeaponDetection", source, weaponHash, "ammo_modification", {
            reportedAmmo = ammo,
            currentAmmo = currentAmmo
        })
        
        return false
    end
    
    return true
end)

-- Weapon component validation
RPC.register("Reaper:ValidateWeaponComponents", function(source, weaponHash, components)
    local player = Player(source)
    if not player then
        return false
    end
    
    local playerPed = GetPlayerPed(source)
    
    -- Check each component
    for _, componentHash in pairs(components) do
        if not HasPedGotWeaponComponent(playerPed, weaponHash, componentHash) then
            log(Logger, string.format("Invalid weapon component: %s on weapon %s (Player: %s)", 
                tostring(componentHash), tostring(weaponHash), player.getName()), "warn")
            
            -- Trigger detection
            RPC.emitLocal("Reaper:WeaponDetection", source, weaponHash, "invalid_component", {
                componentHash = componentHash,
                components = components
            })
            
            return false
        end
    end
    
    return true
end)

-- Weapon lockon validation
RPC.register("Reaper:ValidateWeaponLockon", function(source, weaponHash, target)
    local player = Player(source)
    if not player then
        return false
    end
    
    local playerPed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(target)
    
    -- Get positions
    local playerPos = GetEntityCoords(playerPed)
    local targetPos = GetEntityCoords(targetPed)
    local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, 
        targetPos.x, targetPos.y, targetPos.z, true)
    
    -- Get weapon lockon distance
    local lockonDistance = GetLockonDistanceOfCurrentPedWeapon(weaponHash)
    
    -- Check if lockon distance is exceeded
    if distance > lockonDistance then
        log(Logger, string.format("Weapon lockon distance exceeded: %s - Distance: %.2f, Max Lockon: %.2f (Player: %s)", 
            tostring(weaponHash), distance, lockonDistance, player.getName()), "warn")
        
        -- Trigger detection
        RPC.emitLocal("Reaper:WeaponDetection", source, weaponHash, "lockon_exceeded", {
            distance = distance,
            lockonDistance = lockonDistance,
            target = target
        })
        
        return false
    end
    
    return true
end)

-- Get weapon statistics
RPC.register("Reaper:GetWeaponStats", function(source)
    local player = Player(source)
    if not player then
        return nil
    end
    
    if not player.hasPerm("View Weapon Stats") then
        return nil
    end
    
    return weaponStats
end)

-- Get player weapon detections
RPC.register("Reaper:GetPlayerWeaponDetections", function(source, targetSource)
    local player = Player(source)
    if not player then
        return nil
    end
    
    if not player.hasPerm("View Player Detections") then
        return nil
    end
    
    return weaponDetections[targetSource] or {}
end)

-- Clear weapon detections
RPC.register("Reaper:ClearWeaponDetections", function(source, targetSource)
    local player = Player(source)
    if not player then
        return false
    end
    
    if not player.hasPerm("Clear Player Detections") then
        return false
    end
    
    weaponDetections[targetSource] = {}
    return true
end)

-- Export functions
exports("GetWeaponDetections", function(playerId)
    return weaponDetections[playerId] or {}
end)

exports("GetWeaponStats", function()
    return weaponStats
end)

exports("ClearWeaponDetections", function(playerId)
    weaponDetections[playerId] = {}
    return true
end)

-- Clean up detections for disconnected players
AddEventHandler("playerDropped", function()
    local source = source
    weaponDetections[source] = nil
    
    -- Remove from weapon stats
    for weaponHash, stats in pairs(weaponStats) do
        stats.players[source] = nil
    end
end)
