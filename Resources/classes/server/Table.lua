-- ReaperV4 Server Table Class
-- Clean and optimized version

local table = table
local pairs = pairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local type = type
local tostring = tostring

-- Filter table elements
function table.filter(tbl, predicate)
    local result = {}
    for key, value in pairs(tbl) do
        if predicate(value) then
            table.insert(result, value)
        end
    end
    return result
end

-- Map table elements
function table.map(tbl, mapper)
    local result = {}
    for key, value in pairs(tbl) do
        table.insert(result, mapper(value))
    end
    return result
end

-- Get table keys
function table.keys(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        table.insert(result, key)
    end
    return result
end

-- Concatenate tables
function table.concat_tab(tbl1, tbl2)
    for i = 1, #tbl2 do
        tbl1[#tbl1 + 1] = tbl2[i]
    end
    return tbl1
end

-- Check if table includes value
function table.includes(tbl, value)
    local found = false
    for key, val in pairs(tbl) do
        if val == value then
            found = true
            break
        end
    end
    return found
end

-- Copy table
function table.copy(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        result[key] = value
    end
    return setmetatable(result, getmetatable(tbl))
end

-- Find element in table
function table.find(tbl, predicate)
    for key, value in pairs(tbl) do
        if predicate(value) then
            return value
        end
    end
end

-- Convert numbers to strings in table
function table.numbers_to_string(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    
    local result = {}
    for key, value in pairs(tbl) do
        if type(value) == "number" then
            result[key] = tostring(value)
        elseif type(value) == "table" then
            result[key] = table.numbers_to_string(value)
        else
            result[key] = value
        end
    end
    return result
end

-- Export functions
exports("TableFilter", function(tbl, predicate)
    return table.filter(tbl, predicate)
end)

exports("TableMap", function(tbl, mapper)
    return table.map(tbl, mapper)
end)

exports("TableKeys", function(tbl)
    return table.keys(tbl)
end)

exports("TableConcat", function(tbl1, tbl2)
    return table.concat_tab(tbl1, tbl2)
end)

exports("TableIncludes", function(tbl, value)
    return table.includes(tbl, value)
end)

exports("TableCopy", function(tbl)
    return table.copy(tbl)
end)

exports("TableFind", function(tbl, predicate)
    return table.find(tbl, predicate)
end)

exports("TableNumbersToString", function(tbl)
    return table.numbers_to_string(tbl)
end)