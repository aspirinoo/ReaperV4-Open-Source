-- ReaperV4 Server Natives Class
-- Clean and optimized version

local GetCurrentResourceName = GetCurrentResourceName
local SaveResourceFile = SaveResourceFile
local GetAllVehicles = GetAllVehicles
local GetAllObjects = GetAllObjects
local GetAllPeds = GetAllPeds
local table_concat_tab = table.concat_tab
local Citizen = Citizen

-- Get current resource name
local currentResourceName = GetCurrentResourceName()

-- Save resource file wrapper
function SaveResourceFile(resourceName, fileName, data, dataLength)
    if resourceName == currentResourceName then
        return SaveResourceFile(resourceName, fileName, data, dataLength)
    end
    
    return exports.ReaperV4:SaveResourceFile(resourceName, fileName, data, dataLength)
end

-- Get distance between coordinates
function GetDistanceBetweenCoords(pos1, pos2, useZ)
    local vec1 = vector3(pos1.x, pos1.y, pos1.z)
    local vec2 = vector3(pos2.x, pos2.y, pos2.z)
    
    if useZ then
        return #(vec1 - vec2)
    else
        return #(vec1.xy - vec2.xy)
    end
end

-- Get all entities
function GetAllEntities()
    local entities = {}
    local vehicles = GetAllVehicles()
    local objects = GetAllObjects()
    local peds = GetAllPeds()
    
    entities = table_concat_tab(vehicles, objects)
    entities = table_concat_tab(entities, peds)
    
    return entities
end

-- Network set entity owner
function NetworkSetEntityOwner(entity, owner)
    return Citizen.InvokeNative(2107079555, entity, owner, Citizen.ReturnResultAnyway())
end

-- Is object a pickup
function IsObjectAPickup(object)
    return Citizen.InvokeNative(-1814940775, object, Citizen.ReturnResultAnyway())
end

-- Get entity type raw
function GetEntityTypeRaw(entity)
    return Citizen.InvokeNative(227706051, entity, Citizen.ResultAsInteger())
end

-- Get resource metadata values
function GetResourceMetaDataValues(resourceName, metadataKey)
    local values = {}
    local numMetadata = GetNumResourceMetadata(resourceName, metadataKey) - 1
    
    for i = 0, numMetadata do
        values[#values + 1] = GetResourceMetadata(resourceName, metadataKey, i)
    end
    
    return values
end

-- Export functions
exports("SaveResourceFile", function(resourceName, fileName, data, dataLength)
    return SaveResourceFile(resourceName, fileName, data, dataLength)
end)

exports("GetDistanceBetweenCoords", function(pos1, pos2, useZ)
    return GetDistanceBetweenCoords(pos1, pos2, useZ)
end)

exports("GetAllEntities", function()
    return GetAllEntities()
end)

exports("NetworkSetEntityOwner", function(entity, owner)
    return NetworkSetEntityOwner(entity, owner)
end)

exports("IsObjectAPickup", function(object)
    return IsObjectAPickup(object)
end)

exports("GetEntityTypeRaw", function(entity)
    return GetEntityTypeRaw(entity)
end)

exports("GetResourceMetaDataValues", function(resourceName, metadataKey)
    return GetResourceMetaDataValues(resourceName, metadataKey)
end)