-- ReaperV4 Client Script
-- Clean and optimized version

-- Import required modules
local Security = require('classes.client.Security')
local Logger = require('classes.client.Logger')
local RPC = require('classes.client.RPC')
local Player = require('classes.client.Player')
local NUI = require('classes.client.NUI')
local NativeRules = require('classes.client.NativeRules')

-- Initialize logger
local log = Logger.log
log(Logger, "client.lua loaded", "debug")

-- Get FiveM natives
local GetConvar = GetConvar
local RegisterCommand = RegisterCommand
local Wait = Wait
local CreateThread = CreateThread
local GetGameTimer = GetGameTimer
local GetInvokingResource = GetInvokingResource
local json = json
local json_encode = json.encode
local json_decode = json.decode
local QuitGame = QuitGame or function()
    while true do
        -- Infinite loop as fallback
    end
end

-- Get player state
local LocalPlayer = LocalPlayer
local playerState = LocalPlayer.state
local tostring = tostring
local print = print

-- Table utilities
local table_insert = table.insert
local table_sort = table.sort
local table_reverse = table.reverse

-- State management
local SetLocalStateValue = SetLocalStateValue
local Citizen = Citizen
local GetFunctionReference = Citizen.GetFunctionReference

-- NUI event handlers
NUI.on("httpError", function(data, callback)
    if data.type == "screen.js" then
        print(json_encode(data))
        TriggerServerEvent("Reaper:CustomDrop", "reaperac.com - failed to load needed data")
    end
    callback(true)
end)

-- RPC handlers
RPC.register("invokeCPlayer", function(method, ...)
    return Player[method](Player, ...)
end)

-- Configuration loading
local config = GetConvar("reaper_config", "")
if config == "" then
    config = RPC.await("GetConfig")
else
    config = json_decode(config)
end

-- Game type validation
local gameType = GetConvar("reaper_gameType", "unknown")
if gameType ~= "rdr3" and gameType ~= "gta5" then
    log(Logger, string.format("%s is not a valid game type supported by Reaper.", gameType), "error", true)
    return
end

-- Config validation
if config == "RESPONSE_FAILED" then
    log(Logger, "FAILED TO LOAD CONFIG, STAGE #1", "error")
    TriggerServerEvent("Reaper:CustomDrop", "reaperac.com - FAILED TO LOAD CONFIG, STAGE #1")
    Wait(5000)
    QuitGame()
    return
end

if config ~= "KEY_MISSMATCH" then
    local configHash = Security.hash(config.config)
    if configHash ~= config.key then
        log(Logger, "FAILED TO LOAD CONFIG, STAGE #2", "error", true)
        TriggerServerEvent("Reaper:CustomDrop", "reaperac.com - FAILED TO LOAD CONFIG, STAGE #2")
        Wait(5000)
        QuitGame()
        return
    end
end

-- Config update handler
RPC.onNet("Reaper:UpdateConfig", function(data)
    local decodedData = json_decode(data)
    local configHash = Security.hash(decodedData.config)
    
    if configHash ~= decodedData.key then
        TriggerServerEvent("Reaper:CustomDrop", "reaperac.com - FAILED TO LOAD CONFIG, STAGE #2")
        Wait(5000)
        log(Logger, "FAILED TO LOAD CONFIG, STAGE #2", "error", true)
        return
    end
    
    Player.set("config", json_decode(decodedData.config))
    log(Logger, string.format("Successfully received and verified config from the server. Key: %s", decodedData.key), "debug", true)
    RPC.emit("configUpdated")
    return json_decode(decodedData.config)
end)

-- Set game type and config
Player.set("gameType", gameType)
Player.set("config", json_decode(config.config))
log(Logger, string.format("Successfully received and verified config from the server. Key: %s", config.key), "debug", true)

-- Emit ready event
RPC.emit("reaperReady")
Player.set("reaperReady", true)

-- Register RPC functions
RPC.register("ClipScreen", function()
    return NUI.clipScreen()
end)

RPC.register("ScreenshotScreen", function()
    return NUI.screenshot()
end)

RPC.register("Get_OCR", function()
    return NUI.getOCRText()
end)

-- State management handlers
RPC.onNet("Reaper:SetState", function(state, value)
    local invokingResource = GetInvokingResource()
    if invokingResource ~= nil then
        return
    end
    
    if value == "%GameTimer%" then
        value = GetGameTimer()
    end
    
    Player.set(state, value)
end)

RPC.register("Reaper:SetState", function(state, value)
    local invokingResource = GetInvokingResource()
    if invokingResource ~= nil then
        return
    end
    
    if value == "%GameTimer%" then
        value = GetGameTimer()
    end
    
    Player.set(state, value)
    return true
end)

RPC.onNet("Reaper:setSyncedState", function(state, value)
    if Logger.getLogLevel() == 1 then
        log(Logger, string.format("Reaper:setSyncedState: %s -> %s", state, value), "debug")
    end
    
    Player.set(state .. "_synced", value)
end)

-- State tracking variables
local queuedEvents = {}
local lastEventTime = nil
local eventCount = 0
local processedResources = {}

-- Client state handler
RPC.onNet("Reaper:ClientSetState", function(resource, events)
    local invokingResource = GetInvokingResource()
    if invokingResource == nil then
        return
    end
    
    if resource ~= invokingResource then
        return
    end
    
    if processedResources[resource] then
        return
    end
    
    processedResources[resource] = true
    lastEventTime = GetGameTimer()
    eventCount = eventCount + 1
    
    for _, event in pairs(events) do
        table_insert(queuedEvents, event)
    end
end)

-- Event processing thread
CreateThread(function()
    while true do
        Wait(100)
        
        if lastEventTime then
            local currentTime = GetGameTimer()
            local timeDiff = currentTime - lastEventTime
            
            if timeDiff > 25000 then
                table_sort(queuedEvents, function(a, b)
                    return a.time < b.time
                end)
                
                for _, event in pairs(queuedEvents) do
                    Player.set(event.index, event.data)
                    playerState.set("reaper:" .. Security.hash(event.index), {
                        key = Security.hash(event.index .. tostring(event.data) .. event.time),
                        key2 = event.time,
                        key3 = event.data,
                        eventName = event.index
                    })
                end
                
                Player.set("queued_events", queuedEvents)
                Player.set("start_detections", true)
                break
            end
        end
    end
end)

-- Native recording configuration
local recordNatives = GetConvar("reaper_record_natives", "false") == "true"
local StateRecorder = {}

-- State recorder function
function GetLastStateRecorderData(limit)
    local result = {}
    if limit == nil then
        limit = #StateRecorder
    end
    
    local filteredStates = table.filter(StateRecorder, function(state)
        return not string.match(state.index, "joaat")
    end)
    
    for i, state in pairs(filteredStates) do
        if i <= limit then
            table_insert(result, state)
        end
    end
    
    return result
end

-- Get recorded state data
RPC.register("getLastRecordedStateData", function(filter, limit)
    return table.filter(GetLastStateRecorderData(limit), function(state)
        return filter == ""
    end)
end)

-- State exposure configuration
local exposeState = GetConvar("reaper_expose_state", "false") == "true"
if exposeState then
    RegisterCommand("rdumpstate", function()
        local data = json_encode(GetLastStateRecorderData(#StateRecorder))
        print(string.format("Data: %s", Security.encrypt(data)))
    end)
end

-- State setter exposure
local exposeStateSetters = GetConvar("reaper_expose_state_setters", "false") == "true"

function SetStateData(state, value)
    if not exposeStateSetters then
        return false
    end
    
    local currentTime = GetGameTimer()
    Player.set(state, value)
    playerState.set("reaper:" .. Security.hash(state), {
        key = Security.hash(state .. tostring(value) .. currentTime),
        key2 = currentTime,
        key3 = value,
        eventName = state
    })
    
    return true
end

-- Entity spawn whitelist
local entityWhitelist = {}

-- Request entity spawn export
exports("RequestEntitySpawn", function(entity, data)
    if not exposeStateSetters then
        return false
    end
    
    local invokingResource = GetInvokingResource()
    local autoWhitelist = GetConvar("reaper_auto_entity_whitelist", "false")
    
    if autoWhitelist == "false" then
        return true
    end
    
    if entityWhitelist[entity] then
        return true
    end
    
    local requestString = string.format("exports['ReaperV4'].RequestEntitySpawn('%s')", invokingResource)
    local requestHash = Security.hash(requestString)
    
    local result = RPC.await("requestSpawn", entity, data, requestString, requestHash, requestHash, 
                           Security.hash(requestString .. requestHash), 
                           Security.hash(requestString .. requestHash), "ReaperV4")
    
    entityWhitelist[entity] = result
    return result
end)

-- Execution validation cache
local executionCache = {}

function IsExecutionValid(resource, method, execution, data)
    local invokingResource = GetInvokingResource()
    local proAddonHash = Security.hash("pro_addon")
    
    if config[proAddonHash] == false then
        return {
            true,
            Security.hash(execution .. "yes")
        }
    end
    
    log(Logger, string.format("IsExecutionValid('%s', '%s', '%s', '%s')", resource, method, execution, data), "debug")
    
    local cacheKey = invokingResource .. execution
    if executionCache[cacheKey] == nil then
        local result = RPC.await("check_custom_execution", invokingResource, resource, method, execution, data)
        if result == false then
            return {false, 0}
        end
        executionCache[cacheKey] = Security.hash(execution .. "yes")
    end
    
    return {
        true,
        Security.hash(invokingResource .. execution),
        executionCache[cacheKey]
    }
end

-- State tracker toggle
local stateTrackerEnabled = false

RPC.register("toggle_state_tracker", function()
    stateTrackerEnabled = not stateTrackerEnabled
    return stateTrackerEnabled
end)

-- Set state function
function SetState(state, value, path, id, time, traceback)
    local invokingResource = GetInvokingResource()
    if invokingResource == nil then
        TriggerServerEvent("Reaper:CustomDrop", "reaperac.com - ERROR SETTING STATE #1")
        Wait(5000)
        QuitGame()
        return false
    end
    
    if stateTrackerEnabled then
        local currentValue = Player.get(state)
        if currentValue ~= value then
            RPC.emitNet("Reaper:LogPlayerState", json_encode({
                state = state,
                value = value,
                path = path,
                traceback = traceback,
                invoking_resource = invokingResource,
                id = id
            }, {indent = true}))
        end
    end
    
    Player.set(state, value)
    playerState.set("reaper:" .. Security.hash(state), {
        key = Security.hash(state .. tostring(value) .. time),
        key2 = time,
        key3 = value,
        eventName = state
    })
    
    table_insert(StateRecorder, {
        index = state,
        value = value,
        id = id,
        invoking_resource = invokingResource,
        path = path,
        time = time,
        h_time = GetGameTimer()
    })
    
    if Logger.getLogLevel() == 1 then
        log(Logger, string.format("(state:%s) was just set to (value:%s) from (path:%s) (resource:%s) (id:%s)", 
            state, tostring(value), path, invokingResource, id), "debug", recordNatives)
    end
    
    return true
end

-- Set state 2 function
function SetState2(stateData)
    local currentTime = GetGameTimer()
    local invokingResource = GetInvokingResource()
    
    if stateTrackerEnabled then
        local currentValue = Player.get(stateData.index)
        if currentValue ~= stateData.value then
            RPC.emitNet("Reaper:LogPlayerState", json_encode({
                state = stateData.index,
                value = stateData.value,
                path = stateData.path,
                invoking_resource = invokingResource,
                executionId = stateData.executionId,
                extendedExecutionId = stateData.extendedExecutionId
            }, {indent = true}))
        end
    end
    
    if stateData.native then
        NativeRules.evaluateNative(stateData.native, {
            req = {
                resource = invokingResource,
                path = stateData.path,
                executionId = stateData.executionId,
                extendedExecutionId = stateData.extendedExecutionId
            }
        })
    end
    
    Player.set(stateData.index, stateData.value)
    playerState.set("reaper:" .. Security.hash(stateData.index), {
        key = Security.hash(stateData.index .. tostring(stateData.value) .. currentTime),
        key2 = currentTime,
        key3 = stateData.value,
        eventName = stateData.index
    })
    
    return true
end

-- New detection function
function NewDetection(type, data, path, id)
    return Player.newDetection(type, data, path, id)
end

-- Export functions
local exports = {}
exports.IsExecutionValid = GetFunctionReference(IsExecutionValid)
exports.SetState = GetFunctionReference(SetState)
exports.SetState2 = GetFunctionReference(SetState2)
exports.SetStateData = GetFunctionReference(SetStateData)
exports.NewDetection = GetFunctionReference(NewDetection)

-- Resource stop handler
local resourceKeys = {}
RPC.onNet("onResourceStop", function(resource)
    local invokingResource = GetInvokingResource()
    if invokingResource ~= nil then
        return
    end
    resourceKeys[resource] = nil
end)

-- Get Reaper keys export
exports("GetReaperKeys", function()
    local invokingResource = GetInvokingResource()
    if invokingResource ~= nil then
        if not resourceKeys[invokingResource] then
            return
        end
    end
    resourceKeys[invokingResource] = true
    return exports
end)

-- Clean up global functions
local RequestEntitySpawn = _G.RequestEntitySpawn
local GetExecutionData = _G.GetExecutionData
_G.GetExecutionData = nil
_G.RequestEntitySpawn = nil

-- Vehicle request handler
local vehicleWhitelist = {}
RPC.onNet("Reaper:RequestVehicle", function(vehicle, data)
    Player.set("enteringVehicle", GetGameTimer())
    
    if not vehicleWhitelist[vehicle] then
        local invokingResource = GetInvokingResource()
        if invokingResource == "vMenu" then
            -- Handle vMenu case
        end
        
        local result, success = GetExecutionData(2)
        if RequestEntitySpawn(vehicle, 2, result, success) then
            vehicleWhitelist[vehicle] = true
            playerState.set("reaper:" .. vehicle .. data, true)
        else
            vehicleWhitelist[vehicle] = false
        end
    else
        playerState.set("reaper:" .. vehicle .. data, true)
    end
end)

-- Detection hooks
local detectionHooks = {
    antiTeleport = true,
    antiInvisible = true,
    antiNoClip = true,
    antiFreeCam = true,
    antiFreeCam2 = true,
    antiFreeCam3 = true,
    antiGodMode = true,
    antiVehicleModifier = true,
    antiSkinChanger = true
}

-- Hook detection export
exports("HookDetection", function(detectionType, callback)
    if detectionHooks[detectionType] == nil then
        log(Logger, string.format("[HookDetection] -> Invalid detection name. %s is not a valid detection type", detectionType), "error")
        return
    end
    
    if Player.get("running_detections", false) then
        log(Logger, "[HookDetection] -> Was called too late. This can only be called when the player first joins", "error")
        return
    end
    
    Security.addDetectionHook(detectionType, callback)
    return true
end)

-- Set global state
playerState.ExportsLoaded = true
playerState.ReaperIsRunning = true

-- GTA5 specific pickup disabling
if gameType == "gta5" then
    CreateThread(function()
        local pickupTypes = {
            "PICKUP_AMMO_BULLET_MP", "PICKUP_AMMO_FIREWORK", "PICKUP_AMMO_FLAREGUN",
            "PICKUP_AMMO_GRENADELAUNCHER", "PICKUP_AMMO_GRENADELAUNCHER_MP",
            "PICKUP_AMMO_HOMINGLAUNCHER", "PICKUP_AMMO_MG", "PICKUP_AMMO_MINIGUN",
            "PICKUP_AMMO_MISSILE_MP", "PICKUP_AMMO_PISTOL", "PICKUP_AMMO_RIFLE",
            "PICKUP_AMMO_RPG", "PICKUP_AMMO_SHOTGUN", "PICKUP_AMMO_SMG",
            "PICKUP_AMMO_SNIPER", "PICKUP_ARMOUR_STANDARD", "PICKUP_CAMERA",
            "PICKUP_CUSTOM_SCRIPT", "PICKUP_GANG_ATTACK_MONEY", "PICKUP_HEALTH_SNACK",
            "PICKUP_HEALTH_STANDARD", "PICKUP_MONEY_CASE", "PICKUP_MONEY_DEP_BAG",
            "PICKUP_MONEY_MED_BAG", "PICKUP_MONEY_PAPER_BAG", "PICKUP_MONEY_PURSE",
            "PICKUP_MONEY_SECURITY_CASE", "PICKUP_MONEY_VARIABLE", "PICKUP_MONEY_WALLET",
            "PICKUP_PARACHUTE", "PICKUP_PORTABLE_CRATE_FIXED_INCAR",
            "PICKUP_PORTABLE_CRATE_UNFIXED", "PICKUP_PORTABLE_CRATE_UNFIXED_INCAR",
            "PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL", "PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW",
            "PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE", "PICKUP_PORTABLE_PACKAGE",
            "PICKUP_SUBMARINE", "PICKUP_VEHICLE_ARMOUR_STANDARD",
            "PICKUP_VEHICLE_CUSTOM_SCRIPT", "PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW",
            "PICKUP_VEHICLE_HEALTH_STANDARD", "PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW",
            "PICKUP_VEHICLE_MONEY_VARIABLE", "PICKUP_VEHICLE_WEAPON_APPISTOL",
            "PICKUP_VEHICLE_WEAPON_ASSAULTSMG", "PICKUP_VEHICLE_WEAPON_COMBATPISTOL",
            "PICKUP_VEHICLE_WEAPON_GRENADE", "PICKUP_VEHICLE_WEAPON_MICROSMG",
            "PICKUP_VEHICLE_WEAPON_MOLOTOV", "PICKUP_VEHICLE_WEAPON_PISTOL",
            "PICKUP_VEHICLE_WEAPON_PISTOL50", "PICKUP_VEHICLE_WEAPON_SAWNOFF",
            "PICKUP_VEHICLE_WEAPON_SMG", "PICKUP_VEHICLE_WEAPON_SMOKEGRENADE",
            "PICKUP_VEHICLE_WEAPON_STICKYBOMB", "PICKUP_WEAPON_ADVANCEDRIFLE",
            "PICKUP_WEAPON_APPISTOL", "PICKUP_WEAPON_ASSAULTRIFLE",
            "PICKUP_WEAPON_ASSAULTSHOTGUN", "PICKUP_WEAPON_ASSAULTSMG",
            "PICKUP_WEAPON_AUTOSHOTGUN", "PICKUP_WEAPON_BAT", "PICKUP_WEAPON_BATTLEAXE",
            "PICKUP_WEAPON_BOTTLE", "PICKUP_WEAPON_BULLPUPRIFLE",
            "PICKUP_WEAPON_BULLPUPSHOTGUN", "PICKUP_WEAPON_CARBINERIFLE",
            "PICKUP_WEAPON_COMBATMG", "PICKUP_WEAPON_COMBATPDW",
            "PICKUP_WEAPON_COMBATPISTOL", "PICKUP_WEAPON_COMPACTLAUNCHER",
            "PICKUP_WEAPON_COMPACTRIFLE", "PICKUP_WEAPON_CROWBAR",
            "PICKUP_WEAPON_DAGGER", "PICKUP_WEAPON_DBSHOTGUN",
            "PICKUP_WEAPON_FIREWORK", "PICKUP_WEAPON_FLAREGUN",
            "PICKUP_WEAPON_FLASHLIGHT", "PICKUP_WEAPON_GRENADE",
            "PICKUP_WEAPON_GRENADELAUNCHER", "PICKUP_WEAPON_GUSENBERG",
            "PICKUP_WEAPON_GOLFCLUB", "PICKUP_WEAPON_HAMMER",
            "PICKUP_WEAPON_HATCHET", "PICKUP_WEAPON_HEAVYPISTOL",
            "PICKUP_WEAPON_HEAVYSHOTGUN", "PICKUP_WEAPON_HEAVYSNIPER",
            "PICKUP_WEAPON_HOMINGLAUNCHER", "PICKUP_WEAPON_KNIFE",
            "PICKUP_WEAPON_KNUCKLE", "PICKUP_WEAPON_MACHETE",
            "PICKUP_WEAPON_MACHINEPISTOL", "PICKUP_WEAPON_MARKSMANPISTOL",
            "PICKUP_WEAPON_MARKSMANRIFLE", "PICKUP_WEAPON_MG",
            "PICKUP_WEAPON_MICROSMG", "PICKUP_WEAPON_MINIGUN",
            "PICKUP_WEAPON_MINISMG", "PICKUP_WEAPON_MOLOTOV",
            "PICKUP_WEAPON_MUSKET", "PICKUP_WEAPON_NIGHTSTICK",
            "PICKUP_WEAPON_PETROLCAN", "PICKUP_WEAPON_PIPEBOMB",
            "PICKUP_WEAPON_PISTOL", "PICKUP_WEAPON_PISTOL50",
            "PICKUP_WEAPON_POOLCUE", "PICKUP_WEAPON_PROXMINE",
            "PICKUP_WEAPON_PUMPSHOTGUN", "PICKUP_WEAPON_RAILGUN",
            "PICKUP_WEAPON_REVOLVER", "PICKUP_WEAPON_RPG",
            "PICKUP_WEAPON_SAWNOFFSHOTGUN", "PICKUP_WEAPON_SMG",
            "PICKUP_WEAPON_SMOKEGRENADE", "PICKUP_WEAPON_SNIPERRIFLE",
            "PICKUP_WEAPON_SNSPISTOL", "PICKUP_WEAPON_SPECIALCARBINE",
            "PICKUP_WEAPON_STICKYBOMB", "PICKUP_WEAPON_STUNGUN",
            "PICKUP_WEAPON_SWITCHBLADE", "PICKUP_WEAPON_VINTAGEPISTOL",
            "PICKUP_WEAPON_WRENCH", "PICKUP_WEAPON_RAYCARBINE"
        }
        
        for i = 1, #pickupTypes do
            ToggleUsePickupsForPlayer(PlayerId(), GetHashKey(pickupTypes[i]), false)
        end
    end)
end
