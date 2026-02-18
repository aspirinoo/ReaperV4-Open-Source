-- ReaperV4 Server String Class
-- Clean and optimized version

local string = string
local tonumber = tonumber
local GetHashKey = GetHashKey
local table_insert = table.insert

-- Replace function with regex escaping
function string.replace(str, pattern, replacement)
    -- Escape special regex characters in pattern
    pattern = string.gsub(pattern, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
    
    -- Escape % characters in replacement
    replacement = string.gsub(replacement, "[%%]", "%%%%")
    
    -- Perform replacement
    return string.gsub(str, pattern, replacement)
end

-- Check if string starts with prefix
function string.starts(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

-- Convert string to hash
function string.toHash(str)
    local num = tonumber(str)
    if not num then
        num = GetHashKey(str)
    end
    return num
end

-- Split string by delimiter
function string.split(str, delimiter)
    if not delimiter then
        delimiter = "%s"
    end
    
    local result = {}
    for match in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        table_insert(result, match)
    end
    
    return result
end

-- Export functions
exports("StringReplace", function(str, pattern, replacement)
    return string.replace(str, pattern, replacement)
end)

exports("StringStarts", function(str, prefix)
    return string.starts(str, prefix)
end)

exports("StringToHash", function(str)
    return string.toHash(str)
end)

exports("StringSplit", function(str, delimiter)
    return string.split(str, delimiter)
end)