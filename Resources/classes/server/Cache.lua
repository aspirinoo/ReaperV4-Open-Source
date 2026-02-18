-- ReaperV4 Server Cache Class
-- Clean and optimized version

local class = class
local type = type
local tostring = tostring
local json_encode = json.encode
local json_decode = json.decode
local os_time = os.time
local table_insert = table.insert
local table_remove = table.remove
local table_copy = table.copy

-- Cache class definition
local CacheClass = class("Cache")

-- Constructor
function CacheClass:constructor()
    self.cache = {}
    self.expiry = {}
    self.accessCount = {}
    self.lastAccess = {}
    self.maxSize = 1000
    self.cleanupInterval = 300 -- 5 minutes
end

-- Set cache value
function CacheClass:set(key, value, ttl)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    self.cache[key] = value
    
    if ttl and type(ttl) == "number" then
        self.expiry[key] = os_time() + ttl
    else
        self.expiry[key] = nil
    end
    
    self.accessCount[key] = 0
    self.lastAccess[key] = os_time()
end

-- Get cache value
function CacheClass:get(key, defaultValue)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    -- Check if key exists
    if not self.cache[key] then
        return defaultValue
    end
    
    -- Check if expired
    if self.expiry[key] and os_time() > self.expiry[key] then
        self:remove(key)
        return defaultValue
    end
    
    -- Update access info
    self.accessCount[key] = (self.accessCount[key] or 0) + 1
    self.lastAccess[key] = os_time()
    
    return self.cache[key]
end

-- Remove cache value
function CacheClass:remove(key)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    self.cache[key] = nil
    self.expiry[key] = nil
    self.accessCount[key] = nil
    self.lastAccess[key] = nil
end

-- Check if key exists
function CacheClass:has(key)
    if type(key) ~= "string" then
        error("Key must be a string", 2)
    end
    
    if not self.cache[key] then
        return false
    end
    
    -- Check if expired
    if self.expiry[key] and os_time() > self.expiry[key] then
        self:remove(key)
        return false
    end
    
    return true
end

-- Clear all cache
function CacheClass:clear()
    self.cache = {}
    self.expiry = {}
    self.accessCount = {}
    self.lastAccess = {}
end

-- Get all keys
function CacheClass:keys()
    local keys = {}
    for key, _ in pairs(self.cache) do
        if self:has(key) then
            table_insert(keys, key)
        end
    end
    return keys
end

-- Get cache size
function CacheClass:size()
    local count = 0
    for key, _ in pairs(self.cache) do
        if self:has(key) then
            count = count + 1
        end
    end
    return count
end

-- Get cache statistics
function CacheClass:getStats()
    local stats = {
        size = self:size(),
        maxSize = self.maxSize,
        keys = self:keys(),
        accessCount = table_copy(self.accessCount),
        lastAccess = table_copy(self.lastAccess)
    }
    return stats
end

-- Set cache size limit
function CacheClass:setMaxSize(maxSize)
    if type(maxSize) ~= "number" or maxSize <= 0 then
        error("Max size must be a positive number", 2)
    end
    
    self.maxSize = maxSize
end

-- Get cache size limit
function CacheClass:getMaxSize()
    return self.maxSize
end

-- Clean up expired entries
function CacheClass:cleanup()
    local currentTime = os_time()
    local removed = 0
    
    for key, expiry in pairs(self.expiry) do
        if currentTime > expiry then
            self:remove(key)
            removed = removed + 1
        end
    end
    
    return removed
end

-- Clean up least recently used entries
function CacheClass:cleanupLRU()
    if self:size() <= self.maxSize then
        return 0
    end
    
    local entries = {}
    for key, _ in pairs(self.cache) do
        if self:has(key) then
            table_insert(entries, {
                key = key,
                lastAccess = self.lastAccess[key] or 0,
                accessCount = self.accessCount[key] or 0
            })
        end
    end
    
    -- Sort by last access time
    table.sort(entries, function(a, b)
        return a.lastAccess < b.lastAccess
    end)
    
    local toRemove = self:size() - self.maxSize
    local removed = 0
    
    for i = 1, toRemove do
        if entries[i] then
            self:remove(entries[i].key)
            removed = removed + 1
        end
    end
    
    return removed
end

-- Get cache as JSON
function CacheClass:toJSON()
    local data = {}
    for key, value in pairs(self.cache) do
        if self:has(key) then
            data[key] = value
        end
    end
    return json_encode(data)
end

-- Load cache from JSON
function CacheClass:fromJSON(jsonData)
    if type(jsonData) ~= "string" then
        error("JSON data must be a string", 2)
    end
    
    local data = json_decode(jsonData)
    if type(data) == "table" then
        for key, value in pairs(data) do
            self:set(key, value)
        end
    end
end

-- Create cache instance
Cache = CacheClass.new()

-- Cleanup thread
CreateThread(function()
    while true do
        Cache:cleanup()
        Cache:cleanupLRU()
        Wait(Cache.cleanupInterval * 1000)
    end
end)

-- Export functions
exports("SetCache", function(key, value, ttl)
    return Cache:set(key, value, ttl)
end)

exports("GetCache", function(key, defaultValue)
    return Cache:get(key, defaultValue)
end)

exports("RemoveCache", function(key)
    return Cache:remove(key)
end)

exports("HasCache", function(key)
    return Cache:has(key)
end)

exports("ClearCache", function()
    return Cache:clear()
end)

exports("GetCacheKeys", function()
    return Cache:keys()
end)

exports("GetCacheSize", function()
    return Cache:size()
end)

exports("GetCacheStats", function()
    return Cache:getStats()
end)

exports("SetCacheMaxSize", function(maxSize)
    return Cache:setMaxSize(maxSize)
end)

exports("GetCacheMaxSize", function()
    return Cache:getMaxSize()
end)

exports("CleanupCache", function()
    return Cache:cleanup()
end)

exports("CleanupLRUCache", function()
    return Cache:cleanupLRU()
end)

exports("CacheToJSON", function()
    return Cache:toJSON()
end)

exports("CacheFromJSON", function(jsonData)
    return Cache:fromJSON(jsonData)
end)
