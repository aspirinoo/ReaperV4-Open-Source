-- ReaperV4 Server Weapons Class
-- Clean and optimized version

local class = class
local LoadResourceFile = LoadResourceFile
local GetSelectedPedWeapon = GetSelectedPedWeapon
local json_decode = json.decode
local tostring = tostring

-- Weapons class definition
local WeaponsClass = class("Weapons")

-- Constructor
function WeaponsClass:constructor()
    self.weapon_data = json_decode(LoadResourceFile("ReaperV4", "data_files/weapons.json"))
end

-- Get weapon name
function WeaponsClass:getWeaponName(weaponHash)
    local weaponData = self.weapon_data[tostring(weaponHash)]
    if not weaponData then
        weaponData = {
            Name = tostring(weaponHash)
        }
    end
    return weaponData.Name
end

-- Get weapon data
function WeaponsClass:getWeaponData(weaponHash)
    return self.weapon_data[tostring(weaponHash)]
end

-- Get weapon components
function WeaponsClass:getWeaponComponents(weaponHash)
    local weaponData = self.weapon_data[tostring(weaponHash)]
    if not weaponData then
        weaponData = {}
    end
    return weaponData.Components
end

-- Get current ped weapon
function WeaponsClass:getCurrentPedWeapon(ped)
    local weaponHash = GetSelectedPedWeapon(ped)
    return self.weapon_data[tostring(weaponHash)]
end

-- Create Weapons instance
Weapons = WeaponsClass.new()

-- Export functions
exports("GetWeaponName", function(weaponHash)
    return Weapons:getWeaponName(weaponHash)
end)

exports("GetWeaponData", function(weaponHash)
    return Weapons:getWeaponData(weaponHash)
end)

exports("GetWeaponComponents", function(weaponHash)
    return Weapons:getWeaponComponents(weaponHash)
end)

exports("GetCurrentPedWeapon", function(ped)
    return Weapons:getCurrentPedWeapon(ped)
end)