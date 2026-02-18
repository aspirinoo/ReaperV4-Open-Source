-- ReaperV4 Client String Class
-- Clean and optimized version

local string = string
local string_sub = string.sub
local string_gmatch = string.gmatch
local table_insert = table.insert

-- Check if string starts with prefix
function string.starts(str, prefix)
    if type(str) ~= "string" or type(prefix) ~= "string" then
        return false
    end
    
    return string_sub(str, 1, #prefix) == prefix
end

-- Check if string ends with suffix
function string.ends(str, suffix)
    if type(str) ~= "string" or type(suffix) ~= "string" then
        return false
    end
    
    return string_sub(str, -#suffix) == suffix
end

-- Split string by delimiter
function string.split(str, delimiter)
    if type(str) ~= "string" or type(delimiter) ~= "string" then
        return {}
    end
    
    local result = {}
    for match in string_gmatch(str, "([^" .. delimiter .. "]+)") do
        table_insert(result, match)
    end
    return result
end

-- Join table elements with delimiter
function string.join(tbl, delimiter)
    if type(tbl) ~= "table" then
        return ""
    end
    
    if type(delimiter) ~= "string" then
        delimiter = ""
    end
    
    local result = ""
    for i, v in ipairs(tbl) do
        if i > 1 then
            result = result .. delimiter
        end
        result = result .. tostring(v)
    end
    return result
end

-- Trim whitespace from string
function string.trim(str)
    if type(str) ~= "string" then
        return ""
    end
    
    return string.match(str, "^%s*(.-)%s*$")
end

-- Capitalize first letter
function string.capitalize(str)
    if type(str) ~= "string" or str == "" then
        return str
    end
    
    return string.upper(string_sub(str, 1, 1)) .. string_sub(str, 2)
end

-- Convert to title case
function string.titleCase(str)
    if type(str) ~= "string" then
        return str
    end
    
    local words = string.split(str, " ")
    for i, word in ipairs(words) do
        words[i] = string.capitalize(word)
    end
    return string.join(words, " ")
end

-- Check if string contains substring
function string.contains(str, substring)
    if type(str) ~= "string" or type(substring) ~= "string" then
        return false
    end
    
    return string.find(str, substring, 1, true) ~= nil
end

-- Count occurrences of substring
function string.count(str, substring)
    if type(str) ~= "string" or type(substring) ~= "string" then
        return 0
    end
    
    local count = 0
    local start = 1
    while true do
        local pos = string.find(str, substring, start, true)
        if not pos then
            break
        end
        count = count + 1
        start = pos + 1
    end
    return count
end

-- Replace all occurrences
function string.replaceAll(str, old, new)
    if type(str) ~= "string" or type(old) ~= "string" or type(new) ~= "string" then
        return str
    end
    
    return string.gsub(str, old, new)
end

-- Pad string to specified length
function string.pad(str, length, padChar)
    if type(str) ~= "string" or type(length) ~= "number" then
        return str
    end
    
    if type(padChar) ~= "string" or padChar == "" then
        padChar = " "
    end
    
    if #str >= length then
        return str
    end
    
    local padding = string.rep(padChar, length - #str)
    return str .. padding
end

-- Pad string to specified length (left)
function string.padLeft(str, length, padChar)
    if type(str) ~= "string" or type(length) ~= "number" then
        return str
    end
    
    if type(padChar) ~= "string" or padChar == "" then
        padChar = " "
    end
    
    if #str >= length then
        return str
    end
    
    local padding = string.rep(padChar, length - #str)
    return padding .. str
end

-- Reverse string
function string.reverse(str)
    if type(str) ~= "string" then
        return str
    end
    
    local result = ""
    for i = #str, 1, -1 do
        result = result .. string_sub(str, i, i)
    end
    return result
end

-- Check if string is empty or whitespace
function string.isEmpty(str)
    if type(str) ~= "string" then
        return true
    end
    
    return string.trim(str) == ""
end

-- Generate random string
function string.random(length, charset)
    if type(length) ~= "number" or length <= 0 then
        return ""
    end
    
    if type(charset) ~= "string" or charset == "" then
        charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    end
    
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. string_sub(charset, rand, rand)
    end
    return result
end

-- Format string with arguments
function string.formatArgs(str, ...)
    if type(str) ~= "string" then
        return str
    end
    
    local args = {...}
    return string.format(str, table.unpack(args))
end

-- Export functions
exports("Starts", function(str, prefix)
    return string.starts(str, prefix)
end)

exports("Ends", function(str, suffix)
    return string.ends(str, suffix)
end)

exports("Split", function(str, delimiter)
    return string.split(str, delimiter)
end)

exports("Join", function(tbl, delimiter)
    return string.join(tbl, delimiter)
end)

exports("Trim", function(str)
    return string.trim(str)
end)

exports("Capitalize", function(str)
    return string.capitalize(str)
end)

exports("TitleCase", function(str)
    return string.titleCase(str)
end)

exports("Contains", function(str, substring)
    return string.contains(str, substring)
end)

exports("Count", function(str, substring)
    return string.count(str, substring)
end)

exports("ReplaceAll", function(str, old, new)
    return string.replaceAll(str, old, new)
end)

exports("Pad", function(str, length, padChar)
    return string.pad(str, length, padChar)
end)

exports("PadLeft", function(str, length, padChar)
    return string.padLeft(str, length, padChar)
end)

exports("Reverse", function(str)
    return string.reverse(str)
end)

exports("IsEmpty", function(str)
    return string.isEmpty(str)
end)

exports("Random", function(length, charset)
    return string.random(length, charset)
end)

exports("FormatArgs", function(str, ...)
    return string.formatArgs(str, ...)
end)
