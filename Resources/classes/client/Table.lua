-- ReaperV4 Client Table Class
-- Clean and optimized version

local table = table
local table_insert = table.insert

-- Filter table elements
function table.filter(tbl, predicate)
    if type(tbl) ~= "table" then
        return {}
    end
    
    if type(predicate) ~= "function" then
        error("Predicate must be a function", 2)
    end
    
    local result = {}
    for key, value in pairs(tbl) do
        if predicate(value) then
            table_insert(result, value)
        end
    end
    return result
end

-- Map table elements
function table.map(tbl, mapper)
    if type(tbl) ~= "table" then
        return {}
    end
    
    if type(mapper) ~= "function" then
        error("Mapper must be a function", 2)
    end
    
    local result = {}
    for key, value in pairs(tbl) do
        local mappedValue = mapper(value)
        table_insert(result, mappedValue)
    end
    return result
end

-- Reverse table elements
function table.reverse(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    
    local length = #tbl
    local half = length // 2
    
    for i = 1, half do
        local j = length - i + 1
        local temp = tbl[i]
        tbl[i] = tbl[j]
        tbl[j] = temp
    end
    
    return tbl
end

-- Find element in table
function table.find(tbl, predicate)
    if type(tbl) ~= "table" then
        return nil
    end
    
    if type(predicate) ~= "function" then
        error("Predicate must be a function", 2)
    end
    
    for key, value in pairs(tbl) do
        if predicate(value) then
            return value
        end
    end
    
    return nil
end

-- Check if table contains value
function table.contains(tbl, value)
    if type(tbl) ~= "table" then
        return false
    end
    
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    
    return false
end

-- Get table size
function table.size(tbl)
    if type(tbl) ~= "table" then
        return 0
    end
    
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    
    return count
end

-- Check if table is empty
function table.isEmpty(tbl)
    if type(tbl) ~= "table" then
        return true
    end
    
    return next(tbl) == nil
end

-- Merge tables
function table.merge(tbl1, tbl2)
    if type(tbl1) ~= "table" then
        return tbl2 or {}
    end
    
    if type(tbl2) ~= "table" then
        return tbl1
    end
    
    local result = {}
    
    for key, value in pairs(tbl1) do
        result[key] = value
    end
    
    for key, value in pairs(tbl2) do
        result[key] = value
    end
    
    return result
end

-- Deep copy table
function table.deepCopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    
    local result = {}
    
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            result[key] = table.deepCopy(value)
        else
            result[key] = value
        end
    end
    
    return result
end

-- Get table keys
function table.keys(tbl)
    if type(tbl) ~= "table" then
        return {}
    end
    
    local keys = {}
    for key, _ in pairs(tbl) do
        table_insert(keys, key)
    end
    
    return keys
end

-- Get table values
function table.values(tbl)
    if type(tbl) ~= "table" then
        return {}
    end
    
    local values = {}
    for _, value in pairs(tbl) do
        table_insert(values, value)
    end
    
    return values
end

-- Sort table by key
function table.sortByKey(tbl, compareFunc)
    if type(tbl) ~= "table" then
        return {}
    end
    
    local keys = table.keys(tbl)
    table.sort(keys, compareFunc)
    
    local result = {}
    for _, key in ipairs(keys) do
        table_insert(result, {key = key, value = tbl[key]})
    end
    
    return result
end

-- Group table by function
function table.groupBy(tbl, groupFunc)
    if type(tbl) ~= "table" then
        return {}
    end
    
    if type(groupFunc) ~= "function" then
        error("Group function must be a function", 2)
    end
    
    local groups = {}
    
    for key, value in pairs(tbl) do
        local groupKey = groupFunc(value)
        if not groups[groupKey] then
            groups[groupKey] = {}
        end
        table_insert(groups[groupKey], value)
    end
    
    return groups
end

-- Remove duplicates from table
function table.unique(tbl)
    if type(tbl) ~= "table" then
        return {}
    end
    
    local seen = {}
    local result = {}
    
    for _, value in pairs(tbl) do
        if not seen[value] then
            seen[value] = true
            table_insert(result, value)
        end
    end
    
    return result
end

-- Shuffle table
function table.shuffle(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    
    local result = table.deepCopy(tbl)
    local length = #result
    
    for i = length, 2, -1 do
        local j = math.random(i)
        result[i], result[j] = result[j], result[i]
    end
    
    return result
end

-- Export functions
exports("Filter", function(tbl, predicate)
    return table.filter(tbl, predicate)
end)

exports("Map", function(tbl, mapper)
    return table.map(tbl, mapper)
end)

exports("Reverse", function(tbl)
    return table.reverse(tbl)
end)

exports("Find", function(tbl, predicate)
    return table.find(tbl, predicate)
end)

exports("Contains", function(tbl, value)
    return table.contains(tbl, value)
end)

exports("Size", function(tbl)
    return table.size(tbl)
end)

exports("IsEmpty", function(tbl)
    return table.isEmpty(tbl)
end)

exports("Merge", function(tbl1, tbl2)
    return table.merge(tbl1, tbl2)
end)

exports("DeepCopy", function(tbl)
    return table.deepCopy(tbl)
end)

exports("Keys", function(tbl)
    return table.keys(tbl)
end)

exports("Values", function(tbl)
    return table.values(tbl)
end)

exports("SortByKey", function(tbl, compareFunc)
    return table.sortByKey(tbl, compareFunc)
end)

exports("GroupBy", function(tbl, groupFunc)
    return table.groupBy(tbl, groupFunc)
end)

exports("Unique", function(tbl)
    return table.unique(tbl)
end)

exports("Shuffle", function(tbl)
    return table.shuffle(tbl)
end)