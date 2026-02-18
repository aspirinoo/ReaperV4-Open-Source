-- ReaperV4 Client Weapons Class
-- Clean and optimized version

local class = class
local CreateThread = CreateThread
local LoadResourceFile = LoadResourceFile
local GetSelectedPedWeapon = GetSelectedPedWeapon
local json_decode = json.decode
local json_encode = json.encode
local GetHashKey = GetHashKey
local GetWeaponDamageType = GetWeaponDamageType
local GetWeaponDamageModifier = GetWeaponDamageModifier
local GetMaxRangeOfCurrentPedWeapon = GetMaxRangeOfCurrentPedWeapon
local GetLockonDistanceOfCurrentPedWeapon = GetLockonDistanceOfCurrentPedWeapon
local GetAmmoInPedWeapon = GetAmmoInPedWeapon
local HasPedGotWeaponComponent = HasPedGotWeaponComponent
local GetLabelText = GetLabelText
local PlayerPedId = PlayerPedId
local Wait = Wait

-- Weapons class definition
local WeaponsClass = class("Weapons")

-- Constructor
function WeaponsClass:constructor()
    self.weaponData = {}
    self.weaponHashes = {}
    self.explosiveWeapons = {}
    self.weaponComponents = {}
    self.weaponStats = {}
end

-- Wait for global Weapons to be available
CreateThread(function()
    while _G.Weapons == nil do
        Wait(20)
    end
    Weapons = _G.Weapons
end)

-- Load weapon data
function WeaponsClass:loadWeaponData()
    local weaponDataFile = LoadResourceFile(GetCurrentResourceName(), "data_files/weapons.json")
    if weaponDataFile then
        self.weaponData = json_decode(weaponDataFile)
    end
end

-- Get weapon hash
function WeaponsClass:getWeaponHash(weaponName)
    if type(weaponName) ~= "string" then
        error("Weapon name must be a string", 2)
    end
    
    return GetHashKey(weaponName)
end

-- Get weapon damage type
function WeaponsClass:getWeaponDamageType(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    return GetWeaponDamageType(weaponHash)
end

-- Get weapon damage modifier
function WeaponsClass:getWeaponDamageModifier(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    return GetWeaponDamageModifier(weaponHash)
end

-- Get weapon max range
function WeaponsClass:getWeaponMaxRange(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    return GetMaxRangeOfCurrentPedWeapon(weaponHash)
end

-- Get weapon lockon distance
function WeaponsClass:getWeaponLockonDistance(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    return GetLockonDistanceOfCurrentPedWeapon(weaponHash)
end

-- Get weapon ammo
function WeaponsClass:getWeaponAmmo(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    local ped = PlayerPedId()
    return GetAmmoInPedWeapon(ped, weaponHash)
end

-- Check if ped has weapon component
function WeaponsClass:hasWeaponComponent(weaponHash, componentHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    if type(componentHash) ~= "number" then
        error("Component hash must be a number", 2)
    end
    
    local ped = PlayerPedId()
    return HasPedGotWeaponComponent(ped, weaponHash, componentHash)
end

-- Get weapon label
function WeaponsClass:getWeaponLabel(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    return GetLabelText(weaponHash)
end

-- Get selected weapon
function WeaponsClass:getSelectedWeapon()
    local ped = PlayerPedId()
    return GetSelectedPedWeapon(ped)
end

-- Check if weapon is explosive
function WeaponsClass:isExplosiveWeapon(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    for explosionId, weapons in pairs(WeaponsList.ExplosiveWeapons) do
        if weapons[weaponHash] then
            return true, explosionId
        end
    end
    
    return false, nil
end

-- Get weapon info
function WeaponsClass:getWeaponInfo(weaponHash)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    return {
        hash = weaponHash,
        damageType = self:getWeaponDamageType(weaponHash),
        damageModifier = self:getWeaponDamageModifier(weaponHash),
        maxRange = self:getWeaponMaxRange(weaponHash),
        lockonDistance = self:getWeaponLockonDistance(weaponHash),
        ammo = self:getWeaponAmmo(weaponHash),
        label = self:getWeaponLabel(weaponHash),
        isExplosive = self:isExplosiveWeapon(weaponHash)
    }
end

-- Get all weapon hashes
function WeaponsClass:getAllWeaponHashes()
    local hashes = {}
    
    for weaponName, _ in pairs(self.weaponData) do
        table.insert(hashes, self:getWeaponHash(weaponName))
    end
    
    return hashes
end

-- Get weapon by name
function WeaponsClass:getWeaponByName(weaponName)
    if type(weaponName) ~= "string" then
        error("Weapon name must be a string", 2)
    end
    
    local weaponHash = self:getWeaponHash(weaponName)
    return self:getWeaponInfo(weaponHash)
end

-- Get weapon statistics
function WeaponsClass:getWeaponStats()
    return self.weaponStats
end

-- Update weapon statistics
function WeaponsClass:updateWeaponStats(weaponHash, statType, value)
    if type(weaponHash) ~= "number" then
        error("Weapon hash must be a number", 2)
    end
    
    if not self.weaponStats[weaponHash] then
        self.weaponStats[weaponHash] = {}
    end
    
    self.weaponStats[weaponHash][statType] = value
end

-- Create weapons instance
Weapons = WeaponsClass.new()

-- Load weapon data on initialization
Weapons:loadWeaponData()

-- Export functions
exports("GetWeaponHash", function(weaponName)
    return Weapons:getWeaponHash(weaponName)
end)

exports("GetWeaponDamageType", function(weaponHash)
    return Weapons:getWeaponDamageType(weaponHash)
end)

exports("GetWeaponDamageModifier", function(weaponHash)
    return Weapons:getWeaponDamageModifier(weaponHash)
end)

exports("GetWeaponMaxRange", function(weaponHash)
    return Weapons:getWeaponMaxRange(weaponHash)
end)

exports("GetWeaponLockonDistance", function(weaponHash)
    return Weapons:getWeaponLockonDistance(weaponHash)
end)

exports("GetWeaponAmmo", function(weaponHash)
    return Weapons:getWeaponAmmo(weaponHash)
end)

exports("HasWeaponComponent", function(weaponHash, componentHash)
    return Weapons:hasWeaponComponent(weaponHash, componentHash)
end)

exports("GetWeaponLabel", function(weaponHash)
    return Weapons:getWeaponLabel(weaponHash)
end)

exports("GetSelectedWeapon", function()
    return Weapons:getSelectedWeapon()
end)

exports("IsExplosiveWeapon", function(weaponHash)
    return Weapons:isExplosiveWeapon(weaponHash)
end)

exports("GetWeaponInfo", function(weaponHash)
    return Weapons:getWeaponInfo(weaponHash)
end)

exports("GetWeaponByName", function(weaponName)
    return Weapons:getWeaponByName(weaponName)
end)

exports("GetWeaponStats", function()
    return Weapons:getWeaponStats()
end)
