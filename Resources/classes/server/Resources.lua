-- ReaperV4 Server Resources Class
-- Clean and optimized version

local class = class
local GetNumResources = GetNumResources
local GetResourceByFindIndex = GetResourceByFindIndex
local GetResourcePath = GetResourcePath
local LoadResourceFile = LoadResourceFile
local GetResourceState = GetResourceState
local string_find = string.find
local string_match = string.match
local string_sub = string.sub
local string_gsub = string.gsub
local table_insert = table.insert
local json_decode = json.decode
local tostring = tostring
local io_open = io.open

-- Resources class definition
local ResourcesClass = class("Resources")

-- Constructor
function ResourcesClass:constructor(key)
    self.key = key
    self.vulnerableResources = nil
    self.cache = {}
    self.resources = {}
    self.resources_loaded = false
    
    -- Load all resources
    for i = 0, GetNumResources() - 1 do
        local resourceName = GetResourceByFindIndex(i)
        Resource(resourceName)
    end
    
    self.resources_loaded = true
end

-- Check if resources are loaded
function ResourcesClass:loaded()
    return self.resources_loaded
end

-- Get vulnerable resources
function ResourcesClass:getVulnerableResources()
    if not self.vulnerableResources then
        local response = HTTP:await("https://api.reaperac.com/api/v1/data/vulnerableresources")
        local body = response.body or "{}"
        self.vulnerableResources = json_decode(body)
    end
    return self.vulnerableResources
end

-- Check if resource is vulnerable
function ResourcesClass:isVulnerable(resourceName)
    local cached = self.cache[resourceName]
    if not cached then
        cached = {}
    end
    self.cache[resourceName] = cached
    return self.cache[resourceName]
end

-- Get resource data
function ResourcesClass:getData()
    local resources = {}
    
    for i = 0, GetNumResources() - 1 do
        local resourceName = GetResourceByFindIndex(i)
        local resourcePath = GetResourcePath(resourceName)
        local manifest = LoadResourceFile(resourceName, "fxmanifest.lua")
        
        if not manifest then
            manifest = LoadResourceFile(resourceName, "__resource.lua")
        end
        
        if manifest then
            local state = GetResourceState(resourceName)
            if state ~= "stopped" and resourceName ~= "ReaperV4" then
                local resourceData = {
                    path = string_sub(resourcePath, string_find(resourcePath, "//") + 2, #resourcePath),
                    name = resourceName,
                    protected = string_match(manifest, "@ReaperV4/imports/bypass.lua") ~= nil,
                    needs_protected = string_match(manifest, "client_scripts") or 
                                     string_match(manifest, "client_script") or 
                                     string_match(manifest, "server_script") or 
                                     string_match(manifest, "server_scripts"),
                    vulnerabilities = self:isVulnerable(resourceName)
                }
                
                table_insert(resources, resourceData)
            end
        end
    end
    
    return resources
end

-- Get code near line
function ResourcesClass:getCodeNearLine(resourceName, fileName, lineNumber)
    local cacheKey = tostring(Security:hash(resourceName .. fileName .. lineNumber))
    local cached = Cache:get(cacheKey)
    if cached then
        return cached
    end
    
    local lineCount = 0
    local result = nil
    local resourcePath = GetResourcePath(resourceName)
    
    if LoadResourceFile(resourceName, fileName) then
        local file = io_open(resourcePath .. "/" .. fileName, "r")
        if file then
            result = ""
            for line in self:lines(file) do
                lineCount = lineCount + 1
                if lineCount > lineNumber - 3 and lineCount < lineNumber + 3 then
                    if lineCount == lineNumber then
                        result = result .. string.format("^3[%s]     %s^7\n", lineCount, string_gsub(line, "\n", ""))
                    else
                        result = result .. string.format("[%s]     %s\n", lineCount, string_gsub(line, "\n", ""))
                    end
                end
            end
            file:close()
        end
    end
    
    Cache:set(cacheKey, result)
    return result
end

-- Get code on line
function ResourcesClass:getCodeOnLine(resourceName, fileName, lineNumber)
    local cacheKey = tostring("getCodeOnLine_" .. Security:hash(resourceName .. fileName .. lineNumber))
    local cached = Cache:get(cacheKey)
    if cached then
        return cached
    end
    
    local resourcePath = GetResourcePath(resourceName)
    local result = nil
    local file = io_open(resourcePath .. "/" .. fileName, "r")
    
    if file then
        local lineCount = 0
        for line in self:lines(file) do
            lineCount = lineCount + 1
            if lineCount == lineNumber then
                result = line
                break
            end
        end
        file:close()
    end
    
    return result
end

-- Lines iterator
function ResourcesClass:lines(file)
    local lineNumber = 1
    return function()
        if not lineNumber then
            return nil
        end
        
        local line = string_find(file, "\r?\n", lineNumber)
        local result = nil
        
        if line then
            result = string_sub(file, lineNumber, line - 1)
            lineNumber = line + 1
        else
            result = string_sub(file, lineNumber)
            lineNumber = nil
        end
        
        return result
    end
end

-- Create Resources instance
Resources = ResourcesClass.new()

-- Export functions
exports("GetResources", function()
    return Resources:getData()
end)

exports("GetVulnerableResources", function()
    return Resources:getVulnerableResources()
end)

exports("IsVulnerable", function(resourceName)
    return Resources:isVulnerable(resourceName)
end)

exports("GetCodeNearLine", function(resourceName, fileName, lineNumber)
    return Resources:getCodeNearLine(resourceName, fileName, lineNumber)
end)

exports("GetCodeOnLine", function(resourceName, fileName, lineNumber)
    return Resources:getCodeOnLine(resourceName, fileName, lineNumber)
end)