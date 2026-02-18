-- ReaperV4 Admin Menu Client Script
-- Clean and optimized version

local Logger = Logger
local RPC = RPC
local NUI = NUI
local RegisterKeyMapping = RegisterKeyMapping
local RegisterCommand = RegisterCommand
local GetConvar = GetConvar
local tostring = tostring
local table_unpack = table.unpack
local json_decode = json.decode
local json_encode = json.encode
local GetEntityPlayerIsFreeAimingAt = GetEntityPlayerIsFreeAimingAt
local PlayerId = PlayerId
local NetworkGetEntityIsNetworked = NetworkGetEntityIsNetworked
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local CreateThread = CreateThread
local Wait = Wait
local GetGameTimer = GetGameTimer
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords
local GetEntityHealth = GetEntityHealth
local GetPedArmour = GetPedArmour
local GetPlayerName = GetPlayerName
local GetPlayerIdentifiers = GetPlayerIdentifiers
local GetPlayerEndpoint = GetPlayerEndpoint
local GetPlayerPing = GetPlayerPing
local GetPlayerRoutingBucket = GetPlayerRoutingBucket
local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local DropPlayer = DropPlayer
local TriggerServerEvent = TriggerServerEvent
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local type = type
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_copy = table.copy

-- Admin menu state
local adminMenuOpen = false
local adminMenuData = {}
local adminMenuTarget = nil
local adminMenuTargetData = {}
local adminMenuTargetPosition = nil
local adminMenuTargetHealth = nil
local adminMenuTargetArmor = nil
local adminMenuTargetName = nil
local adminMenuTargetIdentifiers = nil
local adminMenuTargetEndpoint = nil
local adminMenuTargetPing = nil
local adminMenuTargetRoutingBucket = nil
local adminMenuTargetLastUpdate = 0

-- Initialize admin menu
CreateThread(function()
    while not adminMenuData do
        Wait(100)
    end
    
    -- Load admin menu data
    adminMenuData = {
        players = {},
        entities = {},
        vehicles = {},
        peds = {},
        objects = {},
        lastUpdate = 0
    }
end)

-- Open admin menu
function openAdminMenu()
    if adminMenuOpen then
        return
    end
    
    adminMenuOpen = true
    
    -- Get current target
    local target = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if target and target ~= 0 then
        adminMenuTarget = target
        updateTargetData()
    end
    
    -- Send menu data to NUI
    NUI:sendMessage({
        type = "openAdminMenu",
        data = adminMenuData,
        target = adminMenuTarget,
        targetData = adminMenuTargetData
    })
    
    -- Set NUI focus
    NUI:setFocus(true, true)
end

-- Close admin menu
function closeAdminMenu()
    if not adminMenuOpen then
        return
    end
    
    adminMenuOpen = false
    
    -- Send close message to NUI
    NUI:sendMessage({
        type = "closeAdminMenu"
    })
    
    -- Remove NUI focus
    NUI:setFocus(false, false)
end

-- Update target data
function updateTargetData()
    if not adminMenuTarget then
        return
    end
    
    local currentTime = GetGameTimer()
    if currentTime - adminMenuTargetLastUpdate < 1000 then
        return
    end
    
    adminMenuTargetLastUpdate = currentTime
    
    -- Get target position
    adminMenuTargetPosition = GetEntityCoords(adminMenuTarget)
    
    -- Get target health
    adminMenuTargetHealth = GetEntityHealth(adminMenuTarget)
    
    -- Get target armor
    adminMenuTargetArmor = GetPedArmour(adminMenuTarget)
    
    -- Get target name
    adminMenuTargetName = GetPlayerName(adminMenuTarget)
    
    -- Get target identifiers
    adminMenuTargetIdentifiers = GetPlayerIdentifiers(adminMenuTarget)
    
    -- Get target endpoint
    adminMenuTargetEndpoint = GetPlayerEndpoint(adminMenuTarget)
    
    -- Get target ping
    adminMenuTargetPing = GetPlayerPing(adminMenuTarget)
    
    -- Get target routing bucket
    adminMenuTargetRoutingBucket = GetPlayerRoutingBucket(adminMenuTarget)
    
    -- Update target data
    adminMenuTargetData = {
        position = adminMenuTargetPosition,
        health = adminMenuTargetHealth,
        armor = adminMenuTargetArmor,
        name = adminMenuTargetName,
        identifiers = adminMenuTargetIdentifiers,
        endpoint = adminMenuTargetEndpoint,
        ping = adminMenuTargetPing,
        routingBucket = adminMenuTargetRoutingBucket
    }
end

-- Get admin menu data
function getAdminMenuData()
    return adminMenuData
end

-- Get admin menu target
function getAdminMenuTarget()
    return adminMenuTarget
end

-- Get admin menu target data
function getAdminMenuTargetData()
    return adminMenuTargetData
end

-- Set admin menu target
function setAdminMenuTarget(target)
    if type(target) ~= "number" then
        error("Target must be a number", 2)
    end
    
    adminMenuTarget = target
    updateTargetData()
end

-- Clear admin menu target
function clearAdminMenuTarget()
    adminMenuTarget = nil
    adminMenuTargetData = {}
end

-- Update admin menu data
function updateAdminMenuData()
    local currentTime = GetGameTimer()
    if currentTime - adminMenuData.lastUpdate < 5000 then
        return
    end
    
    adminMenuData.lastUpdate = currentTime
    
    -- Update players
    adminMenuData.players = {}
    for _, player in pairs(GetPlayers()) do
        local playerId = tonumber(player)
        if playerId then
            table_insert(adminMenuData.players, {
                id = playerId,
                name = GetPlayerName(playerId),
                ping = GetPlayerPing(playerId),
                endpoint = GetPlayerEndpoint(playerId),
                routingBucket = GetPlayerRoutingBucket(playerId)
            })
        end
    end
    
    -- Update entities
    adminMenuData.entities = {}
    local entities = GetGamePool("CObject")
    for _, entity in pairs(entities) do
        if NetworkGetEntityIsNetworked(entity) then
            table_insert(adminMenuData.entities, {
                id = NetworkGetNetworkIdFromEntity(entity),
                type = "object",
                position = GetEntityCoords(entity),
                health = GetEntityHealth(entity)
            })
        end
    end
    
    -- Update vehicles
    adminMenuData.vehicles = {}
    local vehicles = GetGamePool("CVehicle")
    for _, vehicle in pairs(vehicles) do
        if NetworkGetEntityIsNetworked(vehicle) then
            table_insert(adminMenuData.vehicles, {
                id = NetworkGetNetworkIdFromEntity(vehicle),
                type = "vehicle",
                position = GetEntityCoords(vehicle),
                health = GetEntityHealth(vehicle)
            })
        end
      end
    
    -- Update peds
    adminMenuData.peds = {}
    local peds = GetGamePool("CPed")
    for _, ped in pairs(peds) do
        if NetworkGetEntityIsNetworked(ped) then
            table_insert(adminMenuData.peds, {
                id = NetworkGetNetworkIdFromEntity(ped),
                type = "ped",
                position = GetEntityCoords(ped),
                health = GetEntityHealth(ped),
                armor = GetPedArmour(ped)
            })
        end
    end
  end

-- Handle admin menu commands
function handleAdminMenuCommand(command, data)
    if type(command) ~= "string" then
        error("Command must be a string", 2)
    end
    
    if command == "open" then
        openAdminMenu()
    elseif command == "close" then
        closeAdminMenu()
    elseif command == "update" then
        updateAdminMenuData()
    elseif command == "setTarget" then
        if data and data.target then
            setAdminMenuTarget(data.target)
        end
    elseif command == "clearTarget" then
        clearAdminMenuTarget()
    elseif command == "getData" then
        return getAdminMenuData()
    elseif command == "getTarget" then
        return getAdminMenuTarget()
    elseif command == "getTargetData" then
        return getAdminMenuTargetData()
    end
end

-- Register key mapping
RegisterKeyMapping("reaper_admin_menu", "Open Reaper Admin Menu", "keyboard", "F1")

-- Register command
RegisterCommand("reaper_admin_menu", function()
    openAdminMenu()
end, false)

-- Register NUI callbacks
NUI:on("adminMenuCommand", function(data, cb)
    local result = handleAdminMenuCommand(data.command, data.data)
    cb(result)
end)

NUI:on("adminMenuAction", function(data, cb)
    if data.action == "close" then
        closeAdminMenu()
    elseif data.action == "update" then
        updateAdminMenuData()
    elseif data.action == "setTarget" then
        if data.target then
            setAdminMenuTarget(data.target)
        end
    elseif data.action == "clearTarget" then
        clearAdminMenuTarget()
    end
    cb("ok")
end)

-- Update thread
CreateThread(function()
    while true do
        if adminMenuOpen then
            updateAdminMenuData()
            updateTargetData()
        end
        Wait(1000)
    end
end)

-- Export functions
exports("OpenAdminMenu", function()
    return openAdminMenu()
end)

exports("CloseAdminMenu", function()
    return closeAdminMenu()
end)

exports("GetAdminMenuData", function()
    return getAdminMenuData()
end)

exports("GetAdminMenuTarget", function()
    return getAdminMenuTarget()
end)

exports("GetAdminMenuTargetData", function()
    return getAdminMenuTargetData()
end)

exports("SetAdminMenuTarget", function(target)
    return setAdminMenuTarget(target)
end)

exports("ClearAdminMenuTarget", function()
    return clearAdminMenuTarget()
end)

exports("HandleAdminMenuCommand", function(command, data)
    return handleAdminMenuCommand(command, data)
end)
