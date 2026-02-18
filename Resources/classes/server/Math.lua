-- ReaperV4 Server Math Class
-- Clean and optimized version

local math = math
local type = type

-- Clamp function
function math.clamp(value, min, max)
    if type(value) ~= "number" or type(min) ~= "number" or type(max) ~= "number" then
        return nil
    end
    
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

-- Cosine function with degrees
function math.newcos(degrees)
    return math.cos(math.rad(degrees))
end

-- Sine function with degrees
function math.newsin(degrees)
    return math.sin(math.rad(degrees))
end

-- Export functions
exports("Clamp", function(value, min, max)
    return math.clamp(value, min, max)
end)

exports("NewCos", function(degrees)
    return math.newcos(degrees)
end)

exports("NewSin", function(degrees)
    return math.newsin(degrees)
end)