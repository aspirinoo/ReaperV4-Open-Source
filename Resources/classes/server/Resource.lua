-- ReaperV4 Server Resource Class
-- Clean and optimized version

local class = class
local GetResourceState = GetResourceState
local GetResourceMetadata = GetResourceMetadata
local LoadResourceFile = LoadResourceFile
local GetNumResourceMetadata = GetNumResourceMetadata
local table_insert = table.insert
local table_includes = table.includes
local string_gsub = string.gsub
local type = type

-- Resource class definition
local ResourceClass = class("Resource")

-- Constructor
function ResourceClass:constructor(resourceName)
    self.name = resourceName
    self.state = GetResourceState(resourceName)
    self.fx_version = GetResourceMetadata(resourceName, "fx_version", 0)
    self.game = GetResourceMetadata(resourceName, "game", 0)
    self.author = GetResourceMetadata(resourceName, "author", 0)
    self.version = GetResourceMetadata(resourceName, "version", 0)
    self.description = GetResourceMetadata(resourceName, "description", 0)
    self.this_is_a_map = GetResourceMetadata(resourceName, "this_is_a_map", 0)
    self.lua54 = GetResourceMetadata(resourceName, "this_is_a_map", 0)
    self.escrow_resource = LoadResourceFile(resourceName, ".fxap") ~= nil
    self.weapons_resource = false
    self.vulnerabilities = {}
    self.DATA_FILES = {}
    
    -- Load data files
    local numDataFiles = GetNumResourceMetadata(resourceName, "data_file_extra")
    for i = 0, numDataFiles do
        local dataFile = GetResourceMetadata(resourceName, "data_file", i)
        local dataFileExtra = GetResourceMetadata(resourceName, "data_file_extra", i)
        
        if not dataFileExtra then
            dataFileExtra = ""
        end
        
        dataFileExtra = string_gsub(dataFileExtra, "\"", "")
        
        if dataFile == "WEAPONINFO_FILE" then
            self.weapons_resource = true
        end
        
        if dataFile then
            if not self.DATA_FILES[dataFile] then
                self.DATA_FILES[dataFile] = {}
            end
            table_insert(self.DATA_FILES[dataFile], dataFileExtra)
        end
    end
    
    Logger:log(string.format("^3%s^7 was just registered as a resource", string_gsub(resourceName, "%%20", " ")), "debug")
end

-- Get name
function ResourceClass:getName()
    return string_gsub(self.name, "%%20", " ")
end

-- Get state
function ResourceClass:getState()
    return self.state
end

-- Get version
function ResourceClass:getVersion()
    return self.version
end

-- Is escrow locked
function ResourceClass:isEscrowLocked()
    return self.escrow_resource
end

-- Is weapons resource
function ResourceClass:isWeaponsResource()
    return self.weapons_resource
end

-- Get data files
function ResourceClass:getDataFiles()
    return self.DATA_FILES
end

-- Get data file
function ResourceClass:getDataFile(dataFile)
    return self.DATA_FILES[dataFile] or {}
end

-- Add vulnerability
function ResourceClass:addVulnerability(vulnerability)
    if not table_includes(self.vulnerabilities, vulnerability) then
        table_insert(self.vulnerabilities, vulnerability)
    end
    return 1
end

-- Resource cache
local resourceCache = {}

-- Get resource
function Resource(resourceName)
    if not resourceCache[resourceName] then
        if type(resourceName) == "string" then
            if GetResourceState(resourceName) == "missing" then
                return nil
            end
        end
        
        resourceCache[resourceName] = ResourceClass.new(resourceName)
    end
    
    return resourceCache[resourceName]
end

-- Get all resources
function GetAllResources()
    return resourceCache
end

-- Export functions
exports("GetResource", function(resourceName)
    return Resource(resourceName)
end)

exports("GetAllResources", function()
    return GetAllResources()
end)

exports("GetResourceName", function(resource)
    return resource:getName()
end)

exports("GetResourceState", function(resource)
    return resource:getState()
end)

exports("GetResourceVersion", function(resource)
    return resource:getVersion()
end)

exports("IsEscrowLocked", function(resource)
    return resource:isEscrowLocked()
end)

exports("IsWeaponsResource", function(resource)
    return resource:isWeaponsResource()
end)

exports("GetDataFiles", function(resource)
    return resource:getDataFiles()
end)

exports("GetDataFile", function(resource, dataFile)
    return resource:getDataFile(dataFile)
end)

exports("AddVulnerability", function(resource, vulnerability)
    return resource:addVulnerability(vulnerability)
end)