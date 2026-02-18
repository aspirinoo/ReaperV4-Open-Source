-- ReaperV4 Admin Menu Server Script
-- Clean and optimized version

local Logger = Logger
local RPC = RPC
local Player = Player
local Cache = Cache
local Security = Security
local Settings = Settings
local Command = Command
local HTTP = HTTP
local GetPlayers = GetPlayers
local GetPlayerName = GetPlayerName
local GetPlayerIdentifiers = GetPlayerIdentifiers
local GetPlayerEndpoint = GetPlayerEndpoint
local GetPlayerPing = GetPlayerPing
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local DropPlayer = DropPlayer
local TriggerClientEvent = TriggerClientEvent
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local type = type
local tostring = tostring
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_copy = table.copy
local json_encode = json.encode
local json_decode = json.decode
local os_time = os.time
local math_random = math.random

-- Admin menu state
local adminMenuState = {
    players = {},
    entities = {},
    vehicles = {},
    peds = {},
    objects = {},
    lastUpdate = 0
}

-- Admin menu permissions
local adminMenuPermissions = {
    "reaper.admin",
    "reaper.admin.players",
    "reaper.admin.entities",
    "reaper.admin.vehicles",
    "reaper.admin.peds",
    "reaper.admin.objects",
    "reaper.admin.teleport",
    "reaper.admin.spectate",
    "reaper.admin.freeze",
    "reaper.admin.godmode",
    "reaper.admin.invisible",
    "reaper.admin.noclip",
    "reaper.admin.weapons",
    "reaper.admin.vehicles",
    "reaper.admin.weather",
    "reaper.admin.time",
    "reaper.admin.gravity",
    "reaper.admin.speed",
    "reaper.admin.jump",
    "reaper.admin.swim",
    "reaper.admin.fly"
}

-- Check admin permission
function checkAdminPermission(source, permission)
    if type(source) ~= "number" then
        return false
    end
    
    if type(permission) ~= "string" then
        return false
    end
    
    local player = Player(source)
    if not player then
        return false
    end
    
    return player:hasPermission(permission)
end

-- Get admin menu data
function getAdminMenuData()
    local currentTime = os_time()
    if currentTime - adminMenuState.lastUpdate < 5 then
        return adminMenuState
    end
    
    adminMenuState.lastUpdate = currentTime
    
    -- Update players
    adminMenuState.players = {}
    for _, playerId in pairs(GetPlayers()) do
        local id = tonumber(playerId)
        if id then
            table_insert(adminMenuState.players, {
                id = id,
                name = GetPlayerName(id),
                ping = GetPlayerPing(id),
                endpoint = GetPlayerEndpoint(id),
                routingBucket = GetPlayerRoutingBucket(id),
                identifiers = GetPlayerIdentifiers(id)
            })
        end
    end
    
    return adminMenuState
end

-- Teleport player
function teleportPlayer(source, targetId, x, y, z)
    if not checkAdminPermission(source, "reaper.admin.teleport") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        error("Coordinates must be numbers", 2)
    end
    
    TriggerClientEvent("Reaper:TeleportPlayer", targetId, x, y, z)
    return true
end

-- Teleport to player
function teleportToPlayer(source, targetId)
    if not checkAdminPermission(source, "reaper.admin.teleport") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:TeleportToPlayer", source, targetId)
    return true
end

-- Spectate player
function spectatePlayer(source, targetId)
    if not checkAdminPermission(source, "reaper.admin.spectate") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:SpectatePlayer", source, targetId)
    return true
end

-- Freeze player
function freezePlayer(source, targetId, frozen)
    if not checkAdminPermission(source, "reaper.admin.freeze") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(frozen) ~= "boolean" then
        error("Frozen must be a boolean", 2)
    end
    
    TriggerClientEvent("Reaper:FreezePlayer", targetId, frozen)
    return true
end

-- Set godmode
function setGodmode(source, targetId, godmode)
    if not checkAdminPermission(source, "reaper.admin.godmode") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(godmode) ~= "boolean" then
        error("Godmode must be a boolean", 2)
    end
    
    TriggerClientEvent("Reaper:SetGodmode", targetId, godmode)
    return true
end

-- Set invisible
function setInvisible(source, targetId, invisible)
    if not checkAdminPermission(source, "reaper.admin.invisible") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(invisible) ~= "boolean" then
        error("Invisible must be a boolean", 2)
    end
    
    TriggerClientEvent("Reaper:SetInvisible", targetId, invisible)
    return true
end

-- Set noclip
function setNoclip(source, targetId, noclip)
    if not checkAdminPermission(source, "reaper.admin.noclip") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(noclip) ~= "boolean" then
        error("Noclip must be a boolean", 2)
    end
    
    TriggerClientEvent("Reaper:SetNoclip", targetId, noclip)
    return true
end

-- Give weapon
function giveWeapon(source, targetId, weaponHash, ammo)
    if not checkAdminPermission(source, "reaper.admin.weapons") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    if type(ammo) ~= "number" then
        ammo = 250
    end
    
    TriggerClientEvent("Reaper:GiveWeapon", targetId, weaponHash, ammo)
    return true
end

-- Remove weapon
function removeWeapon(source, targetId, weaponHash)
    if not checkAdminPermission(source, "reaper.admin.weapons") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:RemoveWeapon", targetId, weaponHash)
    return true
end

-- Spawn vehicle
function spawnVehicle(source, targetId, vehicleHash, x, y, z, heading)
    if not checkAdminPermission(source, "reaper.admin.vehicles") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(vehicleHash) ~= "number" then
        error("Vehicle hash must be a number", 2)
    end
    
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        error("Coordinates must be numbers", 2)
    end
    
    if type(heading) ~= "number" then
        heading = 0.0
    end
    
    TriggerClientEvent("Reaper:SpawnVehicle", targetId, vehicleHash, x, y, z, heading)
    return true
end

-- Delete vehicle
function deleteVehicle(source, targetId)
    if not checkAdminPermission(source, "reaper.admin.vehicles") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:DeleteVehicle", targetId)
    return true
end

-- Set weather
function setWeather(source, weatherType)
    if not checkAdminPermission(source, "reaper.admin.weather") then
        return false
    end
    
    if type(weatherType) ~= "string" then
        error("Weather type must be a string", 2)
    end
    
    TriggerClientEvent("Reaper:SetWeather", -1, weatherType)
    return true
end

-- Set time
function setTime(source, hour, minute)
    if not checkAdminPermission(source, "reaper.admin.time") then
        return false
    end
    
    if type(hour) ~= "number" or type(minute) ~= "number" then
        error("Hour and minute must be numbers", 2)
    end
    
    TriggerClientEvent("Reaper:SetTime", -1, hour, minute)
    return true
end

-- Set gravity
function setGravity(source, gravity)
    if not checkAdminPermission(source, "reaper.admin.gravity") then
        return false
    end
    
    if type(gravity) ~= "number" then
        error("Gravity must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:SetGravity", -1, gravity)
    return true
end

-- Set speed
function setSpeed(source, targetId, speed)
    if not checkAdminPermission(source, "reaper.admin.speed") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(speed) ~= "number" then
        error("Speed must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:SetSpeed", targetId, speed)
    return true
end

-- Set jump
function setJump(source, targetId, jump)
    if not checkAdminPermission(source, "reaper.admin.jump") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(jump) ~= "number" then
        error("Jump must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:SetJump", targetId, jump)
    return true
end

-- Set swim
function setSwim(source, targetId, swim)
    if not checkAdminPermission(source, "reaper.admin.swim") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(swim) ~= "number" then
        error("Swim must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:SetSwim", targetId, swim)
    return true
end

-- Set fly
function setFly(source, targetId, fly)
    if not checkAdminPermission(source, "reaper.admin.fly") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(fly) ~= "number" then
        error("Fly must be a number", 2)
    end
    
    TriggerClientEvent("Reaper:SetFly", targetId, fly)
    return true
end

-- Kick player
function kickPlayer(source, targetId, reason)
    if not checkAdminPermission(source, "reaper.admin.players") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(reason) ~= "string" then
        reason = "Kicked by admin"
    end
    
    local player = Player(targetId)
    if player then
        player:kick(reason)
    end
    
    return true
end

-- Ban player
function banPlayer(source, targetId, reason, duration)
    if not checkAdminPermission(source, "reaper.admin.players") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(reason) ~= "string" then
        reason = "Banned by admin"
    end
    
    if type(duration) ~= "number" then
        duration = 0
    end
    
    local player = Player(targetId)
    if player then
        player:ban(reason, duration)
    end
    
    return true
end

-- Set routing bucket
function setRoutingBucket(source, targetId, bucket)
    if not checkAdminPermission(source, "reaper.admin.players") then
        return false
    end
    
    if type(targetId) ~= "number" then
        error("Target ID must be a number", 2)
    end
    
    if type(bucket) ~= "number" then
        error("Bucket must be a number", 2)
    end
    
    SetPlayerRoutingBucket(targetId, bucket)
    return true
end

-- Register admin menu commands
Command:register("admin", function(source, args)
    if not checkAdminPermission(source, "reaper.admin") then
        Logger.log(Logger, string_format("^1Player %s attempted to use admin command without permission", GetPlayerName(source)), "warn")
        return
    end
    
    if #args == 0 then
        Logger.log(Logger, "^3Usage: admin <command> [args]", "info")
        return
    end
    
    local command = args[1]
    table_remove(args, 1)
    
    if command == "teleport" then
        if #args < 4 then
            Logger.log(Logger, "^1Usage: admin teleport <targetId> <x> <y> <z>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local x = tonumber(args[2])
        local y = tonumber(args[3])
        local z = tonumber(args[4])
        
        if teleportPlayer(source, targetId, x, y, z) then
            Logger.log(Logger, string_format("^2Teleported player %s to %f, %f, %f", GetPlayerName(targetId), x, y, z), "info")
        end
    elseif command == "teleportto" then
        if #args < 1 then
            Logger.log(Logger, "^1Usage: admin teleportto <targetId>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        
        if teleportToPlayer(source, targetId) then
            Logger.log(Logger, string_format("^2Teleported to player %s", GetPlayerName(targetId)), "info")
        end
    elseif command == "spectate" then
        if #args < 1 then
            Logger.log(Logger, "^1Usage: admin spectate <targetId>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        
        if spectatePlayer(source, targetId) then
            Logger.log(Logger, string_format("^2Spectating player %s", GetPlayerName(targetId)), "info")
        end
    elseif command == "freeze" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin freeze <targetId> <true/false>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local frozen = args[2] == "true"
        
        if freezePlayer(source, targetId, frozen) then
            Logger.log(Logger, string_format("^2%s player %s", frozen and "Froze" or "Unfroze", GetPlayerName(targetId)), "info")
        end
    elseif command == "godmode" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin godmode <targetId> <true/false>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local godmode = args[2] == "true"
        
        if setGodmode(source, targetId, godmode) then
            Logger.log(Logger, string_format("^2%s godmode for player %s", godmode and "Enabled" or "Disabled", GetPlayerName(targetId)), "info")
        end
    elseif command == "invisible" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin invisible <targetId> <true/false>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local invisible = args[2] == "true"
        
        if setInvisible(source, targetId, invisible) then
            Logger.log(Logger, string_format("^2%s invisibility for player %s", invisible and "Enabled" or "Disabled", GetPlayerName(targetId)), "info")
        end
    elseif command == "noclip" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin noclip <targetId> <true/false>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local noclip = args[2] == "true"
        
        if setNoclip(source, targetId, noclip) then
            Logger.log(Logger, string_format("^2%s noclip for player %s", noclip and "Enabled" or "Disabled", GetPlayerName(targetId)), "info")
        end
    elseif command == "giveweapon" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin giveweapon <targetId> <weaponHash> [ammo]", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local weaponHash = tonumber(args[2])
        local ammo = tonumber(args[3]) or 250
        
        if giveWeapon(source, targetId, weaponHash, ammo) then
            Logger.log(Logger, string_format("^2Gave weapon %d to player %s", weaponHash, GetPlayerName(targetId)), "info")
        end
    elseif command == "removeweapon" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin removeweapon <targetId> <weaponHash>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local weaponHash = tonumber(args[2])
        
        if removeWeapon(source, targetId, weaponHash) then
            Logger.log(Logger, string_format("^2Removed weapon %d from player %s", weaponHash, GetPlayerName(targetId)), "info")
        end
    elseif command == "spawnvehicle" then
        if #args < 5 then
            Logger.log(Logger, "^1Usage: admin spawnvehicle <targetId> <vehicleHash> <x> <y> <z> [heading]", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local vehicleHash = tonumber(args[2])
        local x = tonumber(args[3])
        local y = tonumber(args[4])
        local z = tonumber(args[5])
        local heading = tonumber(args[6]) or 0.0
        
        if spawnVehicle(source, targetId, vehicleHash, x, y, z, heading) then
            Logger.log(Logger, string_format("^2Spawned vehicle %d for player %s", vehicleHash, GetPlayerName(targetId)), "info")
        end
    elseif command == "deletevehicle" then
        if #args < 1 then
            Logger.log(Logger, "^1Usage: admin deletevehicle <targetId>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        
        if deleteVehicle(source, targetId) then
            Logger.log(Logger, string_format("^2Deleted vehicle for player %s", GetPlayerName(targetId)), "info")
        end
    elseif command == "weather" then
        if #args < 1 then
            Logger.log(Logger, "^1Usage: admin weather <weatherType>", "error")
            return
        end
        
        local weatherType = args[1]
        
        if setWeather(source, weatherType) then
            Logger.log(Logger, string_format("^2Set weather to %s", weatherType), "info")
        end
    elseif command == "time" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin time <hour> <minute>", "error")
            return
        end
        
        local hour = tonumber(args[1])
        local minute = tonumber(args[2])
        
        if setTime(source, hour, minute) then
            Logger.log(Logger, string_format("^2Set time to %02d:%02d", hour, minute), "info")
        end
    elseif command == "gravity" then
        if #args < 1 then
            Logger.log(Logger, "^1Usage: admin gravity <gravity>", "error")
            return
        end
        
        local gravity = tonumber(args[1])
        
        if setGravity(source, gravity) then
            Logger.log(Logger, string_format("^2Set gravity to %f", gravity), "info")
        end
    elseif command == "speed" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin speed <targetId> <speed>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local speed = tonumber(args[2])
        
        if setSpeed(source, targetId, speed) then
            Logger.log(Logger, string_format("^2Set speed to %f for player %s", speed, GetPlayerName(targetId)), "info")
        end
    elseif command == "jump" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin jump <targetId> <jump>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local jump = tonumber(args[2])
        
        if setJump(source, targetId, jump) then
            Logger.log(Logger, string_format("^2Set jump to %f for player %s", jump, GetPlayerName(targetId)), "info")
        end
    elseif command == "swim" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin swim <targetId> <swim>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local swim = tonumber(args[2])
        
        if setSwim(source, targetId, swim) then
            Logger.log(Logger, string_format("^2Set swim to %f for player %s", swim, GetPlayerName(targetId)), "info")
        end
    elseif command == "fly" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin fly <targetId> <fly>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local fly = tonumber(args[2])
        
        if setFly(source, targetId, fly) then
            Logger.log(Logger, string_format("^2Set fly to %f for player %s", fly, GetPlayerName(targetId)), "info")
        end
    elseif command == "kick" then
        if #args < 1 then
            Logger.log(Logger, "^1Usage: admin kick <targetId> [reason]", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local reason = args[2] or "Kicked by admin"
        
        if kickPlayer(source, targetId, reason) then
            Logger.log(Logger, string_format("^2Kicked player %s: %s", GetPlayerName(targetId), reason), "info")
        end
    elseif command == "ban" then
        if #args < 1 then
            Logger.log(Logger, "^1Usage: admin ban <targetId> [reason] [duration]", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local reason = args[2] or "Banned by admin"
        local duration = tonumber(args[3]) or 0
        
        if banPlayer(source, targetId, reason, duration) then
            Logger.log(Logger, string_format("^2Banned player %s: %s (Duration: %d)", GetPlayerName(targetId), reason, duration), "info")
        end
    elseif command == "routingbucket" then
        if #args < 2 then
            Logger.log(Logger, "^1Usage: admin routingbucket <targetId> <bucket>", "error")
            return
        end
        
        local targetId = tonumber(args[1])
        local bucket = tonumber(args[2])
        
        if setRoutingBucket(source, targetId, bucket) then
            Logger.log(Logger, string_format("^2Set routing bucket to %d for player %s", bucket, GetPlayerName(targetId)), "info")
        end
    else
        Logger.log(Logger, string_format("^1Unknown admin command: %s", command), "error")
    end
end, "reaper.admin", "Admin commands", "admin <command> [args]", "admin teleport 1 0 0 0")

-- Register admin menu events
RegisterNetEvent("Reaper:AdminMenu:GetData")
AddEventHandler("Reaper:AdminMenu:GetData", function()
    local source = source
    if not checkAdminPermission(source, "reaper.admin") then
        return
    end
    
    local data = getAdminMenuData()
    TriggerClientEvent("Reaper:AdminMenu:Data", source, data)
end)

RegisterNetEvent("Reaper:AdminMenu:Action")
AddEventHandler("Reaper:AdminMenu:Action", function(action, data)
    local source = source
    if not checkAdminPermission(source, "reaper.admin") then
        return
    end
    
    if action == "teleport" then
        teleportPlayer(source, data.targetId, data.x, data.y, data.z)
    elseif action == "teleportto" then
        teleportToPlayer(source, data.targetId)
    elseif action == "spectate" then
        spectatePlayer(source, data.targetId)
    elseif action == "freeze" then
        freezePlayer(source, data.targetId, data.frozen)
    elseif action == "godmode" then
        setGodmode(source, data.targetId, data.godmode)
    elseif action == "invisible" then
        setInvisible(source, data.targetId, data.invisible)
    elseif action == "noclip" then
        setNoclip(source, data.targetId, data.noclip)
    elseif action == "giveweapon" then
        giveWeapon(source, data.targetId, data.weaponHash, data.ammo)
    elseif action == "removeweapon" then
        removeWeapon(source, data.targetId, data.weaponHash)
    elseif action == "spawnvehicle" then
        spawnVehicle(source, data.targetId, data.vehicleHash, data.x, data.y, data.z, data.heading)
    elseif action == "deletevehicle" then
        deleteVehicle(source, data.targetId)
    elseif action == "weather" then
        setWeather(source, data.weatherType)
    elseif action == "time" then
        setTime(source, data.hour, data.minute)
    elseif action == "gravity" then
        setGravity(source, data.gravity)
    elseif action == "speed" then
        setSpeed(source, data.targetId, data.speed)
    elseif action == "jump" then
        setJump(source, data.targetId, data.jump)
    elseif action == "swim" then
        setSwim(source, data.targetId, data.swim)
    elseif action == "fly" then
        setFly(source, data.targetId, data.fly)
    elseif action == "kick" then
        kickPlayer(source, data.targetId, data.reason)
    elseif action == "ban" then
        banPlayer(source, data.targetId, data.reason, data.duration)
    elseif action == "routingbucket" then
        setRoutingBucket(source, data.targetId, data.bucket)
    end
end)

-- Export functions
exports("GetAdminMenuData", function()
    return getAdminMenuData()
end)

exports("TeleportPlayer", function(source, targetId, x, y, z)
    return teleportPlayer(source, targetId, x, y, z)
end)

exports("TeleportToPlayer", function(source, targetId)
    return teleportToPlayer(source, targetId)
end)

exports("SpectatePlayer", function(source, targetId)
    return spectatePlayer(source, targetId)
end)

exports("FreezePlayer", function(source, targetId, frozen)
    return freezePlayer(source, targetId, frozen)
end)

exports("SetGodmode", function(source, targetId, godmode)
    return setGodmode(source, targetId, godmode)
end)

exports("SetInvisible", function(source, targetId, invisible)
    return setInvisible(source, targetId, invisible)
end)

exports("SetNoclip", function(source, targetId, noclip)
    return setNoclip(source, targetId, noclip)
end)

exports("GiveWeapon", function(source, targetId, weaponHash, ammo)
    return giveWeapon(source, targetId, weaponHash, ammo)
end)

exports("RemoveWeapon", function(source, targetId, weaponHash)
    return removeWeapon(source, targetId, weaponHash)
end)

exports("SpawnVehicle", function(source, targetId, vehicleHash, x, y, z, heading)
    return spawnVehicle(source, targetId, vehicleHash, x, y, z, heading)
end)

exports("DeleteVehicle", function(source, targetId)
    return deleteVehicle(source, targetId)
end)

exports("SetWeather", function(source, weatherType)
    return setWeather(source, weatherType)
end)

exports("SetTime", function(source, hour, minute)
    return setTime(source, hour, minute)
end)

exports("SetGravity", function(source, gravity)
    return setGravity(source, gravity)
end)

exports("SetSpeed", function(source, targetId, speed)
    return setSpeed(source, targetId, speed)
end)

exports("SetJump", function(source, targetId, jump)
    return setJump(source, targetId, jump)
end)

exports("SetSwim", function(source, targetId, swim)
    return setSwim(source, targetId, swim)
end)

exports("SetFly", function(source, targetId, fly)
    return setFly(source, targetId, fly)
end)

exports("KickPlayer", function(source, targetId, reason)
    return kickPlayer(source, targetId, reason)
end)

exports("BanPlayer", function(source, targetId, reason, duration)
    return banPlayer(source, targetId, reason, duration)
end)

exports("SetRoutingBucket", function(source, targetId, bucket)
    return setRoutingBucket(source, targetId, bucket)
end)
