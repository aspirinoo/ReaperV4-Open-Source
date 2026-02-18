-- ReaperV4 Server bit32 Class
-- Clean and optimized version

local class = class
local math_floor = math.floor
local math_abs = math.abs

-- bit32 class definition
local bit32Class = class("bit32")

-- Constructor
function bit32Class:constructor()
    -- Initialize bit32 class
end

-- Bitwise NOT
function bit32Class:bnot(value)
    value = value % 4294967296
    return 4294967295 - value
end

-- Bitwise AND
function bit32Class:band(a, b, mask)
    if mask == 255 then
        return a % 256
    end
    if mask == 65535 then
        return a % 65536
    end
    if mask == 4294967295 then
        return a % 4294967296
    end
    
    a = a % 4294967296
    b = b % 4294967296
    
    local result = 0
    local bit = 1
    
    for i = 1, 32 do
        local aBit = a % 2
        local bBit = b % 2
        a = math_floor(a / 2)
        b = math_floor(b / 2)
        
        if aBit + bBit == 2 then
            result = result + bit
        end
        bit = bit * 2
    end
    
    return result
end

-- Bitwise OR
function bit32Class:bor(a, b, mask)
    if mask == 255 then
        return a - (a % 256) + 255
    end
    if mask == 65535 then
        return a - (a % 65536) + 65535
    end
    if mask == 4294967295 then
        return 4294967295
    end
    
    a = a % 4294967296
    b = b % 4294967296
    
    local result = 0
    local bit = 1
    
    for i = 1, 32 do
        local aBit = a % 2
        local bBit = b % 2
        a = math_floor(a / 2)
        b = math_floor(b / 2)
        
        if aBit + bBit >= 1 then
            result = result + bit
        end
        bit = bit * 2
    end
    
    return result
end

-- Left shift
function bit32Class:lshift(value, shift)
    local absShift = math_abs(shift)
    if absShift >= 32 then
        return 0
    end
    
    value = value % 4294967296
    
    if shift < 0 then
        return math_floor(value * (2 ^ shift))
    else
        return (value * (2 ^ shift)) % 4294967296
    end
end

-- Right shift
function bit32Class:rshift(value, shift)
    local absShift = math_abs(shift)
    if absShift >= 32 then
        return 0
    end
    
    value = value % 4294967296
    
    if shift > 0 then
        return math_floor(value / (2 ^ shift))
    else
        return (value * (2 ^ (-shift))) % 4294967296
    end
end

-- Arithmetic right shift
function bit32Class:arshift(value, shift)
    local absShift = math_abs(shift)
    if absShift >= 32 then
        return 0
    end
    
    value = value % 4294967296
    
    if shift > 0 then
        local result = 0
        if value >= 2147483648 then
            local fillBits = 32 - shift
            result = 4294967296 - (2 ^ fillBits)
        end
        return math_floor(value / (2 ^ shift)) + result
    else
        return (value * (2 ^ (-shift))) % 4294967296
    end
end

-- Bitwise XOR
function bit32Class:bxor(a, b)
    a = a % 4294967296
    b = b % 4294967296
    
    local result = 0
    local bit = 1
    
    for i = 1, 32 do
        local aBit = a % 2
        local bBit = b % 2
        a = math_floor(a / 2)
        b = math_floor(b / 2)
        
        if aBit + bBit == 1 then
            result = result + bit
        end
        bit = bit * 2
    end
    
    return result
end

-- Create bit32 instance
bit32 = bit32Class.new()

-- Export functions
exports("bnot", function(value)
    return bit32:bnot(value)
end)

exports("band", function(a, b, mask)
    return bit32:band(a, b, mask)
end)

exports("bor", function(a, b, mask)
    return bit32:bor(a, b, mask)
end)

exports("lshift", function(value, shift)
    return bit32:lshift(value, shift)
end)

exports("rshift", function(value, shift)
    return bit32:rshift(value, shift)
end)

exports("arshift", function(value, shift)
    return bit32:arshift(value, shift)
end)

exports("bxor", function(a, b)
    return bit32:bxor(a, b)
end)