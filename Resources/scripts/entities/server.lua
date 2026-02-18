-- Reaper AntiCheat - Server Entity System
-- Cleaned and deobfuscated version

local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local IsDuplicityVersion = IsDuplicityVersion
local string = string
local load = load
local io = io
local os = os
local json = json
local PerformHttpRequest = PerformHttpRequest
local RPC = RPC
local Logger = Logger
local Security = Security
local Player = Player
local Cache = Cache
local Settings = Settings
local HTTP = HTTP
local GetAllVehicles = GetAllVehicles
local GetAllObjects = GetAllObjects
local GetAllPeds = GetAllPeds
local NetworkGetEntityOwner = NetworkGetEntityOwner
local DeleteEntity = DeleteEntity
local SetPlayerRoutingBucket = SetPlayerRoutingBucket
local SetRoutingBucketPopulationEnabled = SetRoutingBucketPopulationEnabled
local DropPlayer = DropPlayer
local GetEntityModel = GetEntityModel
local GetEntityType = GetEntityType
local GetEntityPopulationType = GetEntityPopulationType
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local GetDistanceBetweenCoords = GetDistanceBetweenCoords
local GetEntityCoords = GetEntityCoords
local GetGameTimer = GetGameTimer
local GetHashKey = GetHashKey
local GetVehicleNumberPlateText = GetVehicleNumberPlateText
local NetworkSetEntityOwner = NetworkSetEntityOwner
local SaveResourceFile = SaveResourceFile
local LoadResourceFile = LoadResourceFile
local GetConvarInt = GetConvarInt
local SetConvar = SetConvar
local SetConvarReplicated = SetConvarReplicated
local GetInvokingResource = GetInvokingResource
local exports = exports
local warn = warn
local type = type
local tostring = tostring
local tonumber = tonumber
local pairs = pairs
local table = table
local math = math

-- Configuration variables
local buildNumber = tonumber(GetConvar("buildNumber", "0"))
local gameName = GetConvar("gamename", "gta5")
local autoPatchNpcPlates = GetConvar("reaper_auto_patch_npc_plates", "true") == "true"
local blockModel0 = GetConvar("reaper_block_model_0", "false") == "true"

-- Entity tracking
local entityTracker = {}
local tempAllowedEntities = {}
local whitelistedEntities = {}
local blacklistedEntities = {}
local autoWhitelistedEntities = {}
local blacklistedSpawnPaths = {}
local entityBlacklist = {}
local entityWhitelist = {}
local autoEntityBlacklist = false
local entityWhitelistEnabled = false
local npcEntities = false
local logEntitiesToConsole = false
local logRestrictedEntitiesToConsole = false
local logEntitiesToFile = false
local underAttackMode = false
local advancedExecutionCheck = false
local entityWhitelistStrictMode = false
local antiEntityExploits = false
local autoEntityWhitelist = false
local maxEntitySpawnDistance = 0
local maxEntitySpawnDistanceEnabled = false

-- Entity type mappings
local pedModels = {}
local vehicleModels = {}
local objectModels = {}

-- Helper functions
local function getEntityModel(entity)
    if not DoesEntityExist(entity) then
        return nil
    end
    return GetEntityModel(entity)
end

local function getEntityName(model, entityType)
    if entityType == 1 then
        return pedModels[tostring(model)] or model
    elseif entityType == 2 then
        return vehicleModels[tostring(model)] or model
    elseif entityType == 3 then
        return objectModels[tostring(model)] or model
    end
    return nil
end

local function getEntityTypeName(entityType)
    if entityType == 1 then
        return "ped"
    elseif entityType == 2 then
        return "vehicle"
    elseif entityType == 3 then
        return "object"
    end
    return "UNKNOWN_ENTITY_TYPE"
end

-- Initialize entity models
CreateThread(function()
    local pedList = IniParser.parseFile("PedList.ini")
    local vehicleList = IniParser.parseFile("VehicleList.ini")
    local objectList = IniParser.parseFile("ObjectList.ini")
    
    for model, _ in pairs(pedList) do
        local hash = GetHashKey(model)
        pedModels[tostring(hash)] = model
    end
    
    for model, _ in pairs(vehicleList) do
        local hash = GetHashKey(model)
        vehicleModels[tostring(hash)] = model
    end
    
    for model, _ in pairs(objectList) do
        local hash = GetHashKey(model)
        objectModels[tostring(hash)] = model
    end
end)

-- Load blacklisted entities from API
RPC.on("reaperReady", function()
    local blacklistedEntitiesData = HTTP.await("https://api.reaperac.com/api/v1/data/blacklistedentities")
    if blacklistedEntitiesData and blacklistedEntitiesData.body then
        local entities = json.decode(blacklistedEntitiesData.body)
        for entityId, data in pairs(entities) do
            local hash = tonumber(entityId)
            if not hash then
                hash = GetHashKey(entityId)
            end
            blacklistedEntities[tostring(hash)] = data
        end
    end
    
    local blacklistedSpawnPathsData = HTTP.await("https://api.reaperac.com/api/v1/data/blacklistedspawnpaths")
    if blacklistedSpawnPathsData and blacklistedSpawnPathsData.body then
        local paths = json.decode(blacklistedSpawnPathsData.body)
        for pathId, data in pairs(paths) do
            if data.type == "entity" then
                table.insert(blacklistedSpawnPaths, data)
            end
        end
    end
end)

-- Load auto whitelisted entities
local autoWhitelistedEntitiesData = json.decode(LoadResourceFile("ReaperV4", "cache/auto_whitelisted_entities.json") or "{}")

-- Save auto whitelisted entities periodically
CreateThread(function()
    local lastHash = nil
    while true do
        Wait(60000)
        local encoded = json.encode(autoWhitelistedEntities)
        local newHash = Security.hash(encoded)
        if newHash ~= lastHash then
            lastHash = newHash
            SaveResourceFile("ReaperV4", "cache/auto_whitelisted_entities.json", encoded, #encoded)
        end
    end
end)

-- Load entities cache
local entitiesCache = json.decode(LoadResourceFile("ReaperV4", "cache/entities.json") or "{}")
local proAddonWhitelisters = {}

-- Pro Addon integration
RPC.onLocal("ProAddon:AddWhitelister", function(playerId)
    proAddonWhitelisters[tostring(playerId)] = true
end)

RPC.on("ProAddon:RefreshEntities", function()
    local entitiesData = LoadResourceFile("ReaperV4", "cache/entities.json")
    if entitiesData then
        entitiesCache = json.decode(entitiesData)
    end
end)

-- Configuration update handler
RPC.on("configUpdated", function(config)
    advancedExecutionCheck = config.AdvancedExecutionCheck
    npcEntities = config.entityRules.npcEntities
    entityWhitelistEnabled = config.entityRules.entityWhitelist.enabled
    underAttackMode = config.underAttackMode
    
    SetConvar("reaper_log_spawned_entities_to_file", tostring(config.entityRules.logEntitiesToFile or false))
    
    local logFilterPop = GetConvarInt("reaper_log_spawned_entities_to_file_filter_pop", -1)
    local logFilterType = GetConvarInt("reaper_log_spawned_entities_to_file_filter_type", -1)
    local logFilterResource = GetConvar("reaper_log_spawned_entities_to_file_filter_resource", "")
    
    entityWhitelist = {}
    for _, entity in pairs(config.entityRules.entityWhitelist.allowedEntities) do
        local hash = tonumber(entity)
        if not hash then
            hash = GetHashKey(entity)
        end
        entityWhitelist[hash] = true
    end
    
    -- Add parachute models to whitelist
    local parachuteModels = {
        GetHashKey("p_parachute_s"),
        GetHashKey("p_parachute1_mp_dec"),
        GetHashKey("p_parachute1_s"),
        GetHashKey("p_parachute1_mp_s"),
        GetHashKey("p_parachute1_sp_dec"),
        GetHashKey("prop_v_parachute"),
        GetHashKey("p_parachute_fallen_s"),
        GetHashKey("p_parachute_s_shop"),
        GetHashKey("prop_parachute"),
        GetHashKey("p_parachute1_sp_s"),
        GetHashKey("hei_bio_heist_parachute"),
        GetHashKey("hei_p_parachute_s_female"),
        GetHashKey("hei_prison_heist_parachute")
    }
    
    for _, model in pairs(parachuteModels) do
        entityWhitelist[model] = true
    end
    
    if gameName == "rdr3" and not npcEntities then
        Logger.log("Please note ^3NPC Peds/Vehicles^7 was disabled in the config. This may cause performance issue if you do not disable them in your code also", "warn")
    end
    
    entityBlacklist = {}
    for _, rule in pairs(config.entityRules.entityBlacklist) do
        local parts = string.split(rule, "=")
        local model = tonumber(parts[1])
        if not model then
            model = GetHashKey(parts[1])
        end
        entityBlacklist[model] = {
            action = parts[2],
            model = parts[1]
        }
    end
    
    logRestrictedEntitiesToConsole = config.entityRules.logRestrictedEntitiesToConsole
    logEntitiesToConsole = config.entityRules.logEntitiesToConsole
    
    local logToFile = GetConvar("reaper_log_spawned_entities_to_file", "false") == "true"
    if logToFile and npcEntities then
        logToFile = false
        Logger.log("^3reaper_log_spawned_entities_to_file^7 can not be used when ^3NPC Entities^7 is enabled.", "error")
    end
    
    autoEntityBlacklist = config.entityRules.autoEntityBlacklist
    SetRoutingBucketPopulationEnabled(0, npcEntities)
    SetConvarReplicated("reaper_onesync_population", tostring(npcEntities))
    
    if config.generalRules.antiEntityExploits then
        local os = System.getOs()
        if os ~= "Windows" then
            Logger.log("^3Anti Entity Exploits^7 is enabled but is unable to be used. This option can only be used on ^3windows^7 servers.", "warn")
            config.generalRules.antiEntityExploits = false
        end
    end
    
    if config.generalRules.antiEntityExploits then
        if not Logger.customArtifacts() then
            config.generalRules.antiEntityExploits = false
            Logger.log("^3Anti Entity Exploits^7 is enabled but is unable to be used. This option can only be used when running our custom artifacts.", "warn")
        end
    end
    
    autoEntityWhitelist = config.entityRules.entityWhitelist.autoWhitelist
    SetConvarReplicated("reaper_auto_entity_whitelist", tostring(autoEntityWhitelist))
    
    entityWhitelistStrictMode = config.entityRules.entityWhitelist.whitelistStrictMode
    antiEntityExploits = config.generalRules.antiEntityExploits
    SetConvarReplicated("anti_entity_exploits", tostring(antiEntityExploits))
    
    SetConvar("sv_filterRequestControl", "4")
    
    autoPatchNpcPlates = GetConvar("reaper_auto_patch_npc_plates", "false") == "true"
    blockModel0 = GetConvar("reaper_block_model_0", "false") == "true"
    
    maxEntitySpawnDistance = config.entityRules.maxEntitySpawnDistance.max_distance
    maxEntitySpawnDistanceEnabled = config.entityRules.maxEntitySpawnDistance.enabled
end)

-- Request control handler
RPC.register("requestControl", function(source, netId, entityType, executionId, extendedExecutionId)
    if not antiEntityExploits then
        return false
    end
    
    local player = Player(source)
    if not player then
        return
    end
    
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then
        return false
    end
    
    if not ExecutionCheck.execution_valid(player.getId(), "NetworkRequestControlOfEntity", executionId, entityType, extendedExecutionId, getEntityModel(entity) or "invalid_entity") then
        return false
    end
    
    player.NewLog("^3%s^7 (^3id:%s^7) just requested control of the (^3net:%s^7) from ^3%s:%s^7", "info", "entities", {}, true)
    NetworkSetEntityOwner(entity, player.getId())
    return true
end)

-- Entity creating handler
RPC.onLocal("entityCreating", function(entity)
    local model = getEntityModel(entity)
    local entityType = GetEntityType(entity)
    local owner = NetworkGetEntityOwner(entity)
    local popType = GetEntityPopulationType(entity)
    local player = Player(owner)
    
    if not player then
        CancelEvent()
        return
    end
    
    if underAttackMode then
        CancelEvent()
        Logger.log("[UAM] An entity was just created by ^3%s ^7(^3id:%s^7) was blocked. Data: (^3model:%s^7) (^3netId:%s^7) (^3type:%s^7) (^3pop:%s^7) (^3coords:%s^7) (^3%s^7)", "info")
        return
    end
    
    if not model then
        return
    end
    
    if advancedExecutionCheck then
        local rawType = GetEntityTypeRaw(entity)
        if rawType == 7 or rawType == 8 then
            CancelEvent()
            return
        end
    elseif entityType == 0 and popType == 0 and model == 0 then
        CancelEvent()
        return
    end
    
    if gameName == "gta5" and model == 0 then
        if blockModel0 then
            CancelEvent()
        end
        return
    end
    
    -- Check blacklisted entities
    local blacklistRule = entityBlacklist[tostring(model)]
    if blacklistRule then
        CancelEvent()
        RPC.emitLocal("Reaper:NewDetection", {
            type = "blacklistedEntity",
            data = {
                model = blacklistRule.model,
                entityType = entityType,
                popType = popType
            },
            params = {blacklistRule.model},
            action = blacklistRule.action
        }, owner)
        return
    end
    
    -- Check auto blacklisted entities
    if autoEntityBlacklist then
        local autoBlacklistRule = blacklistedEntities[tostring(model)]
        if autoBlacklistRule and not entityWhitelist[model] then
            CancelEvent()
            RPC.emitLocal("Reaper:NewDetection", {
                type = "autoBlacklistedEntity",
                data = {
                    model = model,
                    entityType = entityType,
                    popType = popType
                },
                params = {model},
                action = autoBlacklistRule
            }, owner)
            return
        end
    end
    
    -- Check spawn distance
    if popType ~= 5 and popType ~= 2 and popType ~= 4 then
        if maxEntitySpawnDistanceEnabled then
            local distance = GetDistanceBetweenCoords(player.getCoords(), GetEntityCoords(entity))
            if distance > maxEntitySpawnDistance then
                RPC.emitLocal("Reaper:NewDetection", {
                    type = "entityMaxSpawnDistance",
                    data = {
                        model = model,
                        entityType = entityType,
                        popType = popType
                    },
                    params = {model, distance}
                }, owner)
                CancelEvent()
                return
            end
        end
    end
    
    -- Check temp allowed entities
    local tempAllowed = tempAllowedEntities[model]
    if tempAllowed then
        local currentTime = GetGameTimer()
        if currentTime - tempAllowed.time > 5000 then
            tempAllowedEntities[model] = nil
        end
    end
    
    -- Check entity whitelist
    if entityWhitelistEnabled then
        local playerMeta = player.getMeta("%s:%s", model, entityType)
        if not playerMeta then
            local isWhitelisted = entityWhitelist[model]
            if not isWhitelisted then
                -- Check if it's an NPC entity
                if npcEntities then
                    if (entityType == 1 and popType == 5) or (entityType == 1 and popType == 4) then
                        isWhitelisted = true
                    elseif gameName == "rdr3" and entityType == 1 and popType == 6 then
                        isWhitelisted = true
                    elseif (entityType == 2 and popType == 5) or (entityType == 2 and popType == 2) then
                        isWhitelisted = true
                    elseif gameName == "rdr3" and entityType == 2 and popType == 6 then
                        isWhitelisted = true
                    end
                end
                
                if entityWhitelistStrictMode then
                    isWhitelisted = false
                end
                
                if entityType == 1 and popType == 0 then
                    isWhitelisted = true
                end
                
                if not isWhitelisted then
                    CancelEvent()
                    if logRestrictedEntitiesToConsole and popType ~= 5 then
                        Logger.log("^3entityCreating^7: An entity created by ^3%s^7 (^3id:%s^7) was deleted due to no auth. Data: (^3model:%s^7) (^3type:%s^7) (^3pop:%s^7)", "warn")
                    end
                    return
                end
            end
        end
    end
end)

-- Entity created handler
RPC.onLocal("entityCreated", function(entity)
    if not DoesEntityExist(entity) then
        return
    end
    
    local entityType = GetEntityType(entity)
    local model = getEntityModel(entity)
    local netId = tostring(NetworkGetNetworkIdFromEntity(entity))
    local owner = NetworkGetFirstEntityOwner(entity)
    local popType = GetEntityPopulationType(entity)
    
    -- Handle vehicle plate patching
    if entityType == 2 and autoPatchNpcPlates then
        local plate = GetVehicleNumberPlateText(entity)
        Entity(entity).state:set("VehiclePlate", plate, true)
    end
    
    -- Mark NPC vehicles
    if entityType == 2 and (popType == 5 or popType == 2) then
        Entity(entity).state:set("Reaper_NPC_Vehicle", true, true)
    end
    
    local player = Player(owner)
    if player then
        if model then
            local trackerData = nil
            local tempAllowed = tempAllowedEntities[model]
            if tempAllowed then
                trackerData = {
                    type = "temp_allowed_entities",
                    value = tempAllowed,
                    creator = "random",
                    owner = owner,
                    last_owner = owner
                }
            else
                local playerMeta = player.getMeta("%s:%s", model, entityType)
                if playerMeta then
                    trackerData = {
                        type = "player_requested",
                        value = playerMeta,
                        creator = owner,
                        owner = owner,
                        last_owner = owner
                    }
                else
                    if entityWhitelist[model] then
                        trackerData = {
                            type = "whitelisted_entities",
                            value = {},
                            creator = owner,
                            owner = owner,
                            last_owner = owner
                        }
                    else
                        trackerData = {
                            type = "unknown",
                            value = {},
                            creator = owner,
                            owner = owner,
                            last_owner = owner
                        }
                    end
                end
            end
            
            entityTracker[netId] = trackerData
            
            -- Handle auto whitelist for player requested entities
            if trackerData.type == "player_requested" then
                local autoWhitelist = GetConvar("reaper_ai_auto_whitelist", "true")
                if autoWhitelist == "true" then
                    local resourceHash = Security.hash(trackerData.value.resource, "97ae7727-b78e47fc-075ea9de-c852f7da-44587eed")
                    local executionKey = tostring(trackerData.value.extendedExecutionId) .. ":" .. trackerData.value.path
                    local executionCount = autoWhitelistedEntities[resourceHash] and autoWhitelistedEntities[resourceHash][executionKey] or 0
                    
                    if executionCount <= 3 then
                        local playerCount = GetConvarInt("reaper_server_player_count", 0)
                        if playerCount >= 10 then
                            player.NewLog("^3%s^7 (^3id:%s^7) just spawned ^3%s^7 from ^3%s^7 with an uncommon execution id. ID: ^3%s^7", "warn", "uncommon_executions", {
                                type = "entity",
                                tracker_data = trackerData
                            })
                        end
                    end
                end
            end
        end
        
        if model then
            local entityName = getEntityName(model, entityType)
            if entityName and entityName ~= model then
                if logEntitiesToConsole then
                    Logger.log("A %s was just created by ^3%s ^7(^3id:%s^7). Data: (^3model:%s^7) (^3netId:%s^7) (^3type:%s^7) (^3pop:%s^7) (^3coords:%s^7) (^3%s^7)", "info")
                end
                
                if (entityType == 1 and popType ~= 4 and popType ~= 5) or (entityType == 2 and popType ~= 5 and popType ~= 2) or entityType == 3 then
                    player.NewLog("^3%s^7 (^3id:%s^7) just spawned a %s (^3model:%s^7) from ^3%s:%s^7", "info", "entities", {
                        entity_type = getEntityTypeName(entityType),
                        model_hash = model,
                        entity_model_name = entityName,
                        resource = entityTracker[netId] and entityTracker[netId].value and entityTracker[netId].value.resource or "UNKNOWN_RESOURCE",
                        tacker_data = entityTracker[netId]
                    }, true)
                end
            end
            
            -- Log to file if enabled
            if logEntitiesToFile then
                local shouldLog = false
                local logFilterPop = GetConvarInt("reaper_log_spawned_entities_to_file_filter_pop", -1)
                local logFilterType = GetConvarInt("reaper_log_spawned_entities_to_file_filter_type", -1)
                local logFilterResource = GetConvar("reaper_log_spawned_entities_to_file_filter_resource", "")
                
                if logFilterPop == -1 or logFilterPop == popType then
                    shouldLog = true
                end
                if logFilterType == -1 or logFilterType == entityType then
                    shouldLog = true
                end
                if logFilterResource == "" or (entityTracker[netId] and entityTracker[netId].resource == logFilterResource) then
                    shouldLog = true
                end
                
                if shouldLog then
                    Logger.log_to_file("spawned_entities.txt", "%s (license:%s). Data: (model:%s) (netId:%s) (type:%s) (pop:%s) (coords:%s) (%s)")
                end
            end
        end
    end
end)

-- Entity removed handler
RPC.onLocal("entityRemoved", function(entity)
    if not DoesEntityExist(entity) then
        return
    end
    
    local netId = tostring(NetworkGetNetworkIdFromEntity(entity))
    entityTracker[netId] = nil
end)

-- Request spawn handler
RPC.register("requestSpawn", function(source, model, entityType, path, executionId, extendedExecutionId, hash, resource, invResource, extraData)
    if not autoEntityWhitelist then
        return false
    end
    
    local player = Player(source)
    if not player then
        return
    end
    
    local entityName = getEntityName(model, entityType)
    if not entityName then
        entityName = model
    end
    
    local entityTypeName = getEntityTypeName(entityType)
    
    player.NewLog("^3%s^7 (^3id:%s^7) just requested to spawn a %s (^3model:%s^7) from the resource ^3%s:%s^7 (^3%s^7)", "info", "entities", {
        event = "requestSpawn",
        resource = resource,
        inv_resource = invResource,
        model = model,
        executionId = executionId,
        extendedExecutionId = extendedExecutionId,
        extra_data = extraData
    }, true)
    
    -- Verify hash
    local expectedHash = Security.hash(model .. path .. executionId)
    if expectedHash ~= hash then
        RPC.emitLocal("Reaper:NewDetection", {
            type = "keyMissmatch",
            data = {
                model = model,
                path = path,
                executionId = executionId,
                extendedExecutionId = extendedExecutionId,
                set = blacklistedSpawnPaths[path]
            },
            params = {"EntityRequest:1"},
            action = "Ban Player"
        }, player.getId())
        return false
    end
    
    -- Check blacklisted spawn paths
    local blacklistedPath = blacklistedSpawnPaths[path]
    if not blacklistedPath then
        for _, pathData in pairs(blacklistedSpawnPaths) do
            if string.match(path, pathData.filter) then
                blacklistedPath = pathData
                break
            end
        end
        blacklistedSpawnPaths[path] = blacklistedPath or false
    end
    
    if blacklistedPath and blacklistedPath.action then
        RPC.emitLocal("Reaper:NewDetection", {
            type = "autoBlacklistedEntity",
            data = {
                model = model,
                path = path,
                executionId = executionId,
                extendedExecutionId = extendedExecutionId,
                set = blacklistedPath
            },
            params = {model},
            action = blacklistedPath.action
        }, player.getId())
        return false
    end
    
    -- Check auto blacklisted entities
    if autoEntityBlacklist then
        local autoBlacklistRule = blacklistedEntities[tostring(model)]
        if autoBlacklistRule and not entityWhitelist[model] then
            RPC.emitLocal("Reaper:NewDetection", {
                type = "autoBlacklistedEntity",
                data = {
                    catch = "requestSpawn",
                    model = model,
                    path = path,
                    executionId = executionId,
                    extendedExecutionId = extendedExecutionId,
                    set = blacklistedPath
                },
                params = {model},
                action = autoBlacklistRule
            }, player.getId())
            return false
        end
    end
    
    -- Handle auto whitelist
    if autoEntityWhitelist then
        local executionKey = tostring(executionId)
        if not entitiesCache[executionKey] then
            local playerId = tostring(player.getId())
            local isWhitelisted = proAddonWhitelisters[playerId]
            if not isWhitelisted then
                local globalWhitelist = Cache.get("ProAddon:AutoWhitelist")
                if globalWhitelist ~= true then
                    local resourceWhitelist = Cache.get("ProAddon:AutoWhitelist:" .. resource)
                    if resourceWhitelist ~= true then
                        RPC.emitLocal("Reaper:UnknownExecutionPath", {
                            type = "entity",
                            resource = resource,
                            param = model,
                            path = path,
                            key = executionId,
                            extendedExecutionId = extendedExecutionId,
                            source = player.getId()
                        })
                        return false
                    end
                end
            end
            
            entitiesCache[executionKey] = {
                type = "entity",
                resource = resource,
                param = model,
                path = path,
                key = executionId,
                extendedExecutionId = extendedExecutionId
            }
            
            local encoded = json.encode(entitiesCache)
            SaveResourceFile("ReaperV4", "cache/entities.json", encoded, #encoded)
            
            player.NewLog("(^3CreateEntity('%s')^7) (^3%s^7) sent from (^3%s^7) by (^3%s^7) (^3id:%s^7) was auto whitelisted", "warn", "pro_addon", {
                resource = resource,
                model = model,
                path = path,
                executionId = executionId,
                extendedExecutionId = extendedExecutionId
            })
        end
    end
    
    -- Handle AI auto whitelist
    local aiAutoWhitelist = GetConvar("reaper_ai_auto_whitelist", "true")
    if aiAutoWhitelist == "true" then
        local resourceHash = Security.hash(resource, "97ae7727-b78e47fc-075ea9de-c852f7da-44587eed")
        local executionKey = tostring(extendedExecutionId) .. ":" .. path
        
        if not autoWhitelistedEntities[resourceHash] then
            autoWhitelistedEntities[resourceHash] = {}
        end
        
        local playerMeta = player.getMeta("ai_whitelist_" .. executionKey, false)
        if not playerMeta then
            local executionCount = autoWhitelistedEntities[resourceHash][executionKey] or 0
            if executionCount <= 3 then
                local globalWhitelist = Cache.get("ai_whitelist_" .. executionKey, 0)
                if globalWhitelist <= 3 then
                    autoWhitelistedEntities[resourceHash][executionKey] = (autoWhitelistedEntities[resourceHash][executionKey] or 0) + 1
                end
            end
            player.setMeta("ai_whitelist_" .. executionKey, true)
        end
        
        local executionCount = autoWhitelistedEntities[resourceHash][executionKey] or 0
        if executionCount <= 3 then
            local blockUncommon = GetConvar("reaper_ai_auto_whitelist_block", "false")
            if blockUncommon == "true" then
                player.NewLog("^3%s^7 (^3id:%s^7) just attempted to spawn ^3%s^7 from ^3%s^7 with an uncommon execution id. ID: ^3%s^7", "warn", "uncommon_executions", {
                    type = "entity",
                    resource = resource,
                    inv_resource = invResource,
                    param = model,
                    path = path,
                    key = executionId,
                    extendedExecutionId = extendedExecutionId,
                    extra_data = extraData or "na"
                })
                return false
            end
        end
    end
    
    -- Evaluate native rules
    local nativeName = "CreatePed"
    if entityType == 2 then
        nativeName = "CreateVehicle"
    elseif entityType == 3 then
        nativeName = "CreateObject"
    end
    
    if not NativeRules.evaluateNative(nativeName, {
        req = {
            resource = resource,
            path = path,
            executionId = executionId,
            extendedExecutionId = extendedExecutionId
        },
        origin = {
            player = player.getId(),
            source = "client->server->cb"
        }
    }) then
        return false
    end
    
    -- Set player metadata
    player.setMeta("%s:%s", model, entityType, {
        type = "entity",
        resource = resource,
        inv_resource = invResource,
        param = model,
        path = path,
        key = executionId,
        extendedExecutionId = extendedExecutionId,
        extra_data = extraData or "na"
    })
    
    return true
end)

-- Temp allow entity handler
RPC.register("Reaper:TempAllowEntity", function(source, model)
    local player = Player(source)
    if player then
        player.addDetection("ban", "Attempting to trigger Reaper:TempAllowEntity")
    end
    return false
end)

-- Export for temp allow entity
exports("tempAllowEntity", function(model, path)
    local resource = GetInvokingResource()
    if not model or (type(model) ~= "string" and type(model) ~= "number") then
        return true
    end
    
    tempAllowedEntities[model] = {
        time = GetGameTimer(),
        resource = resource or "unknown",
        path = path
    }
    
    Logger.log("^3%s^7 was just set as a temp allowed entity - %s", "debug")
    return true
end)

-- Request entity info handler
RPC.register("requestEntityInfo", function(source, netId)
    local info = entityTracker[tostring(netId)]
    if info then
        info.netId = netId
    end
    return info
end)

-- Entity ownership transfer handler
RPC.onLocal("entityOwnershipTransfer", function(netId, fromPlayer, toPlayer)
    local tracker = entityTracker[tostring(netId)]
    if not tracker then
        local logUnknown = GetConvar("reaper_log_unknown_entity_ownership_transfers", "false")
        if logUnknown == "true" then
            local entity = NetworkGetEntityFromNetworkId(netId)
            if entity ~= 0 then
                warn("(netId:%s) (model:%s) (type:%s) (pop:%s) is an unknown entity, unable to set entity ownership data.")
            end
        end
        return
    end
    
    tracker.last_owner = fromPlayer
    tracker.owner = toPlayer
    
    local logChanges = GetConvar("reaper_log_entity_ownership_changes", "false")
    if logChanges == "true" then
        local newOwner = Player(toPlayer)
        local oldOwner = Player(fromPlayer)
        
        if not newOwner or not oldOwner then
            return
        end
        
        local entity = NetworkGetEntityFromNetworkId(netId)
        local entityType = GetEntityType(entity)
        local message = ""
        
        if entityType == 1 then
            message = "^3%s^7 (^3id:%s^7) was just transferred ownership of the ped (^3netId:%s^7) from ^3%s^7 (^3id:%s^7)"
        elseif entityType == 2 then
            message = "^3%s^7 (^3id:%s^7) was just transferred ownership of the vehicle (^3netId:%s^7) from ^3%s^7 (^3id:%s^7)"
        elseif entityType == 3 then
            message = "^3%s^7 (^3id:%s^7) was just transferred ownership of the object (^3netId:%s^7) from ^3%s^7 (^3id:%s^7)"
        end
        
        if entityType == 1 then
            local logToFile = GetConvar("reaper_log_ped_ownership_changes_to_file", "false")
            if logToFile == "true" then
                Logger.log_to_file("entities/ped_ownerships.log", message)
            end
        end
        
        if entityType == 2 then
            local logToFile = GetConvar("reaper_log_vehicle_ownership_changes_to_file", "false")
            if logToFile == "true" then
                Logger.log_to_file("entities/vehicle_ownerships.log", message)
            end
        end
        
        if entityType == 3 then
            local logToFile = GetConvar("reaper_log_object_ownership_changes_to_file", "false")
            if logToFile == "true" then
                Logger.log_to_file("entities/object_ownerships.log", message)
            end
        end
        
        Logger.log(message, "info")
    end
end)

-- Anti NPC vehicle attach handler
RPC.onNet("Reaper:antiNPCVehicleAttach", function(netId)
    local source = source
    local entity = NetworkGetEntityFromNetworkId(netId)
    local owner = NetworkGetFirstEntityOwner(entity)
    local tracker = entityTracker[tostring(netId)]
    
    if tracker then
        owner = tracker.last_owner
    end
    
    if entity == 0 then
        return
    end
    
    DeleteEntity(entity)
    
    local player = Player(source)
    local lastOwner = Player(owner)
    
    if not player then
        return
    end
    
    if not lastOwner then
        lastOwner = {
            getName = function() return "Unknown" end,
            getId = function() return 0 end
        }
    end
    
    Logger.log("(^3net:%s^7) was just deleted after being attached to ^3%s^7 (^3id:%s^7). The last owner was ^3%s^7 (^3id:%s^7)", "warn")
end)