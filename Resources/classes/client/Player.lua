-- ReaperV4 Client Player Class
-- Clean and optimized version

local class = class
local tostring = tostring
local playerState = LocalPlayer.state
local string_byte = string.byte
local IsPedInAnyVehicle = IsPedInAnyVehicle
local GetEntityCoords = GetEntityCoords
local GetSelectedPedWeapon = GetSelectedPedWeapon
local PlayerPedId = PlayerPedId
local GetGameTimer = GetGameTimer
local json_encode = json.encode
local GetRenderingCam = GetRenderingCam
local IsEntityVisible = IsEntityVisible
local type = type
local Logger = Logger
local CreateThread = CreateThread

-- Player class definition
local PlayerClass = class("PlayerClient")

-- Constructor
function PlayerClass:constructor()
    self.state = {}
    self.meta = {}
    self.config = {}
    self.gameType = "gta5"
    self.reaperReady = false
end

-- Wait for Security to be available
CreateThread(function()
    while _G.Security == nil do
        Wait(100)
    end
    self.security = _G.Security
end)

-- Set player state
function PlayerClass:set(key, value)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    self.state[key] = value
    playerState[key] = value
end

-- Get player state
function PlayerClass:get(key, defaultValue)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    return self.state[key] or defaultValue
end

-- Set player metadata
function PlayerClass:setMeta(key, value)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    self.meta[key] = value
end

-- Get player metadata
function PlayerClass:getMeta(key, defaultValue)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    return self.meta[key] or defaultValue
end

-- Set config
function PlayerClass:setConfig(config)
    if type(config) ~= "table" then
        error("Config must be a table", 2)
    end
    
    self.config = config
end

-- Get config
function PlayerClass:getConfig()
    return self.config
end

-- Set game type
function PlayerClass:setGameType(gameType)
    if type(gameType) ~= "string" then
        error("Game type must be a string", 2)
    end
    
    self.gameType = gameType
end

-- Get game type
function PlayerClass:getGameType()
    return self.gameType
end

-- Set reaper ready state
function PlayerClass:setReaperReady(ready)
    self.reaperReady = ready
end

-- Get reaper ready state
function PlayerClass:isReaperReady()
    return self.reaperReady
end

-- Get player position
function PlayerClass:getPosition()
    local ped = PlayerPedId()
    return GetEntityCoords(ped)
end

-- Get player vehicle
function PlayerClass:getVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

-- Get selected weapon
function PlayerClass:getSelectedWeapon()
    local ped = PlayerPedId()
    return GetSelectedPedWeapon(ped)
end

-- Get player health
function PlayerClass:getHealth()
    local ped = PlayerPedId()
    return GetEntityHealth(ped)
end

-- Get player armor
function PlayerClass:getArmor()
    local ped = PlayerPedId()
    return GetPedArmour(ped)
end

-- Check if player is in vehicle
function PlayerClass:isInVehicle()
    local ped = PlayerPedId()
    return IsPedInAnyVehicle(ped, false)
end

-- Check if player is visible
function PlayerClass:isVisible()
    local ped = PlayerPedId()
    return IsEntityVisible(ped)
end

-- Get player camera
function PlayerClass:getCamera()
    return GetRenderingCam()
end

-- Get player data as JSON
function PlayerClass:getDataAsJSON()
    local data = {
        state = self.state,
        meta = self.meta,
        config = self.config,
        gameType = self.gameType,
        reaperReady = self.reaperReady,
        position = self:getPosition(),
        vehicle = self:getVehicle(),
        weapon = self:getSelectedWeapon(),
        health = self:getHealth(),
        armor = self:getArmor(),
        inVehicle = self:isInVehicle(),
        visible = self:isVisible(),
        camera = self:getCamera()
    }
    
    return json_encode(data)
end

-- New detection
function PlayerClass:newDetection(type, data, path, id)
    if type(type) ~= "string" then
        error("Detection type must be a string", 2)
    end
    
    if type(data) ~= "table" then
        error("Detection data must be a table", 2)
    end
    
    local detection = {
        type = type,
        data = data,
        path = path or "unknown",
        id = id or GetGameTimer(),
        timestamp = GetGameTimer(),
        playerId = PlayerId()
    }
    
    -- Log detection
    Logger.log(Logger, string.format("New detection: %s - %s", type, json_encode(data)), "warn")
    
    return detection
end

-- Create player instance
Player = PlayerClass.new()

-- Export functions
exports("SetPlayerState", function(key, value)
    return Player:set(key, value)
end)

exports("GetPlayerState", function(key, defaultValue)
    return Player:get(key, defaultValue)
end)

exports("SetPlayerMeta", function(key, value)
    return Player:setMeta(key, value)
end)

exports("GetPlayerMeta", function(key, defaultValue)
    return Player:getMeta(key, defaultValue)
end)

exports("GetPlayerPosition", function()
    return Player:getPosition()
end)

exports("GetPlayerVehicle", function()
    return Player:getVehicle()
end)

exports("GetPlayerWeapon", function()
    return Player:getSelectedWeapon()
end)

exports("GetPlayerHealth", function()
    return Player:getHealth()
end)

exports("GetPlayerArmor", function()
    return Player:getArmor()
end)

exports("IsPlayerInVehicle", function()
    return Player:isInVehicle()
end)

exports("IsPlayerVisible", function()
    return Player:isVisible()
end)

exports("GetPlayerData", function()
    return Player:getDataAsJSON()
end)
