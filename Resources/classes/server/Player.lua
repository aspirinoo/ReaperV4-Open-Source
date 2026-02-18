-- ReaperV4 Server Player Class
-- Clean and optimized version

local class = class
local GetPlayerName = GetPlayerName
local GetPlayerIdentifiers = GetPlayerIdentifiers
local GetPlayerEndpoint = GetPlayerEndpoint
local GetPlayerPing = GetPlayerPing
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords
local GetEntityHealth = GetEntityHealth
local GetPedArmour = GetPedArmour
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local DropPlayer = DropPlayer
local type = type
local tostring = tostring
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local json_encode = json.encode
local json_decode = json.decode
local Logger = Logger
local RPC = RPC

-- Player class definition
local PlayerClass = class("Player")

-- Constructor
function PlayerClass:constructor(source)
    self.source = source
    self.name = GetPlayerName(source)
    self.identifiers = {}
    self.meta = {}
    self.permissions = {}
    self.flags = {}
    self.warnings = {}
    self.kicks = {}
    self.bans = {}
    self.joinTime = os.time()
    self.firstSeen = os.time()
    self.lastSeen = os.time()
    self.isOnline = true
end

-- Get player name
function PlayerClass:getName()
    return self.name
end

-- Get player source
function PlayerClass:getSource()
    return self.source
end

-- Get player identifiers
function PlayerClass:getIdentifiers()
    if not self.identifiers or #self.identifiers == 0 then
        self.identifiers = GetPlayerIdentifiers(self.source)
    end
    return self.identifiers
end

-- Get specific identifier
function PlayerClass:getIdentifier(type)
    local identifiers = self:getIdentifiers()
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, type .. ":") then
            return identifier
        end
    end
    return nil
end

-- Get player endpoint
function PlayerClass:getEndpoint()
    return GetPlayerEndpoint(self.source)
end

-- Get player ping
function PlayerClass:getPing()
    return GetPlayerPing(self.source)
end

-- Get player position
function PlayerClass:getPosition()
    local ped = GetPlayerPed(self.source)
    if ped and ped ~= 0 then
        return GetEntityCoords(ped)
    end
    return nil
end

-- Get player health
function PlayerClass:getHealth()
    local ped = GetPlayerPed(self.source)
    if ped and ped ~= 0 then
        return GetEntityHealth(ped)
    end
    return nil
end

-- Get player armor
function PlayerClass:getArmor()
    local ped = GetPlayerPed(self.source)
    if ped and ped ~= 0 then
        return GetPedArmour(ped)
    end
    return nil
end

-- Get routing bucket
function PlayerClass:getRoutingBucket()
    return GetPlayerRoutingBucket(self.source)
end

-- Set routing bucket
function PlayerClass:setRoutingBucket(bucket)
    if type(bucket) ~= "number" then
        error("Routing bucket must be a number", 2)
    end
    
    SetPlayerRoutingBucket(self.source, bucket)
end

-- Set metadata
function PlayerClass:setMeta(key, value)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    self.meta[key] = value
end

-- Get metadata
function PlayerClass:getMeta(key, defaultValue)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    return self.meta[key] or defaultValue
end

-- Add permission
function PlayerClass:addPermission(permission)
    if type(permission) ~= "string" then
        error("Permission must be a string", 2)
    end
    
    if not self.permissions[permission] then
        self.permissions[permission] = true
    end
end

-- Remove permission
function PlayerClass:removePermission(permission)
    if type(permission) ~= "string" then
        error("Permission must be a string", 2)
    end
    
    self.permissions[permission] = nil
end

-- Check permission
function PlayerClass:hasPermission(permission)
    if type(permission) ~= "string" then
        error("Permission must be a string", 2)
    end
    
    return self.permissions[permission] == true
end

-- Add flag
function PlayerClass:addFlag(flag)
    if type(flag) ~= "string" then
        error("Flag must be a string", 2)
    end
    
    if not self.flags[flag] then
        self.flags[flag] = true
    end
end

-- Remove flag
function PlayerClass:removeFlag(flag)
    if type(flag) ~= "string" then
        error("Flag must be a string", 2)
    end
    
    self.flags[flag] = nil
end

-- Check flag
function PlayerClass:hasFlag(flag)
    if type(flag) ~= "string" then
        error("Flag must be a string", 2)
    end
    
    return self.flags[flag] == true
end

-- Add warning
function PlayerClass:addWarning(reason, admin)
    if type(reason) ~= "string" then
        error("Warning reason must be a string", 2)
    end
    
    local warning = {
        reason = reason,
        admin = admin or "System",
        timestamp = os.time()
    }
    
    table_insert(self.warnings, warning)
end

-- Get warnings
function PlayerClass:getWarnings()
    return self.warnings
end

-- Add kick
function PlayerClass:addKick(reason, admin)
    if type(reason) ~= "string" then
        error("Kick reason must be a string", 2)
    end
    
    local kick = {
        reason = reason,
        admin = admin or "System",
        timestamp = os.time()
    }
    
    table_insert(self.kicks, kick)
end

-- Get kicks
function PlayerClass:getKicks()
    return self.kicks
end

-- Add ban
function PlayerClass:addBan(reason, admin, duration)
    if type(reason) ~= "string" then
        error("Ban reason must be a string", 2)
    end
    
    local ban = {
        reason = reason,
        admin = admin or "System",
        duration = duration or 0,
        timestamp = os.time()
    }
    
    table_insert(self.bans, ban)
end

-- Get bans
function PlayerClass:getBans()
    return self.bans
end

-- Kick player
function PlayerClass:kick(reason)
    if type(reason) ~= "string" then
        reason = "Kicked by server"
    end
    
    self:addKick(reason)
    DropPlayer(self.source, reason)
end

-- Ban player
function PlayerClass:ban(reason, duration)
    if type(reason) ~= "string" then
        reason = "Banned by server"
    end
    
    self:addBan(reason, nil, duration)
    DropPlayer(self.source, reason)
end

-- Get player data
function PlayerClass:getData()
    return {
        source = self.source,
        name = self.name,
        identifiers = self:getIdentifiers(),
        endpoint = self:getEndpoint(),
        ping = self:getPing(),
        position = self:getPosition(),
        health = self:getHealth(),
        armor = self:getArmor(),
        routingBucket = self:getRoutingBucket(),
        meta = self.meta,
        permissions = self.permissions,
        flags = self.flags,
        warnings = self.warnings,
        kicks = self.kicks,
        bans = self.bans,
        joinTime = self.joinTime,
        firstSeen = self.firstSeen,
        lastSeen = self.lastSeen,
        isOnline = self.isOnline
    }
end

-- Get player data as JSON
function PlayerClass:getDataAsJSON()
    return json_encode(self:getData())
end

-- Update last seen
function PlayerClass:updateLastSeen()
    self.lastSeen = os.time()
end

-- Set online status
function PlayerClass:setOnline(online)
    self.isOnline = online
end

-- Get online status
function PlayerClass:isOnline()
    return self.isOnline
end

-- Create player instance
function PlayerClass:new(source)
    return PlayerClass(source)
end

-- Export functions
exports("GetPlayerName", function(source)
    local player = Player(source)
    if player then
        return player:getName()
    end
    return nil
end)

exports("GetPlayerIdentifiers", function(source)
    local player = Player(source)
    if player then
        return player:getIdentifiers()
    end
    return nil
end)

exports("GetPlayerIdentifier", function(source, type)
    local player = Player(source)
    if player then
        return player:getIdentifier(type)
    end
    return nil
end)

exports("GetPlayerEndpoint", function(source)
    local player = Player(source)
    if player then
        return player:getEndpoint()
    end
    return nil
end)

exports("GetPlayerPing", function(source)
    local player = Player(source)
    if player then
        return player:getPing()
    end
    return nil
end)

exports("GetPlayerPosition", function(source)
    local player = Player(source)
    if player then
        return player:getPosition()
    end
    return nil
end)

exports("GetPlayerHealth", function(source)
    local player = Player(source)
    if player then
        return player:getHealth()
    end
    return nil
end)

exports("GetPlayerArmor", function(source)
    local player = Player(source)
    if player then
        return player:getArmor()
    end
    return nil
end)

exports("GetPlayerData", function(source)
    local player = Player(source)
    if player then
        return player:getData()
    end
    return nil
end)

exports("GetPlayerDataAsJSON", function(source)
    local player = Player(source)
    if player then
        return player:getDataAsJSON()
    end
    return nil
end)
