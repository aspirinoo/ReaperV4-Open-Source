-- ReaperV4 Server INI Parser Class
-- Clean and optimized version

local class = class
local LoadResourceFile = LoadResourceFile
local json_decode = json.decode
local string_split = string.split
local string_match = string.match

-- INI Parser class definition
local IniParserClass = class("IniParserServer")

-- Constructor
function IniParserClass:constructor()
    self.weapon_data = json_decode(LoadResourceFile("ReaperV4", "data_files/weapons.json"))
end

-- Parse INI file
function IniParserClass:parseFile(filename)
    local filePath = string.format("data_files/%s", filename)
    local content = LoadResourceFile("ReaperV4", filePath)
    
    if not content then
        return {}
    end
    
    local result = {}
    local currentSection = nil
    
    for _, line in pairs(string_split(content, "\n")) do
        -- Trim whitespace
        line = string_match(line, "^%s*(.-)%s*$")
        
        -- Check if line is a section header
        if string_match(line, "^%[.-%]$") then
            local sectionName = string_match(line, "^%[(.-)%]$")
            currentSection = {}
            result[sectionName] = currentSection
        else
            -- Check if line is a key-value pair
            if string_match(line, "^[^%[%]=]+=[^%[%]=]*$") then
                local key, value = string_match(line, "^(.-)=(.*)$")
                key = string_match(key, "^%s*(.-)%s*$")
                value = string_match(value, "^%s*(.-)%s*$")
                
                if currentSection then
                    currentSection[key] = value
                end
            end
        end
    end
    
    return result
end

-- Create INI Parser instance
IniParser = IniParserClass.new()

-- Export functions
exports("ParseIniFile", function(filename)
    return IniParser:parseFile(filename)
end)

exports("GetWeaponData", function()
    return IniParser.weapon_data
end)