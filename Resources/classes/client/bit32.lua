-- ReaperV4 Client Bit32 Class
-- Clean and optimized version

local class = class

-- Bit32 class definition
local Bit32Class = class("bit32")

-- Constructor
function Bit32Class:constructor()
    -- Constructor implementation
end

-- Bitwise NOT operation
function Bit32Class:bnot(value)
    value = value % 4294967296
    return 4294967295 - value
end

-- Bitwise AND operation
function Bit32Class:band(a, b)
    if b == 255 then
        return a % 256
    end
    if b == 65535 then
        return a % 65536
    end
    if b == 4294967295 then
        return a % 4294967296
    end
    
    a = a % 4294967296
    b = b % 4294967296
    
    local result = 0
    local bit = 1
    
    for i = 1, 32 do
        local bitA = a % 2
        local bitB = b % 2
        
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        
        if bitA + bitB == 2 then
            result = result + bit
        end
        
        bit = bit * 2
    end
    
    return result
end

-- Bitwise OR operation
function Bit32Class:bor(a, b)
    if b == 255 then
        return a - (a % 256) + 255
    end
    if b == 65535 then
        return a - (a % 65536) + 65535
    end
    if b == 4294967295 then
        return 4294967295
    end
    
    a = a % 4294967296
    b = b % 4294967296
    
    local result = 0
    local bit = 1
    
    for i = 1, 32 do
        local bitA = a % 2
        local bitB = b % 2
        
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        
        if bitA + bitB >= 1 then
            result = result + bit
        end
        
        bit = bit * 2
    end
    
    return result
end

-- Left shift operation
function Bit32Class:lshift(value, shift)
    if math.abs(shift) >= 32 then
        return 0
    end
    
    value = value % 4294967296
    
    if shift < 0 then
        return math.floor(value * (2 ^ shift))
    else
        return (value * (2 ^ shift)) % 4294967296
    end
end

-- Right shift operation
function Bit32Class:rshift(value, shift)
    if math.abs(shift) >= 32 then
        return 0
    end
    
    value = value % 4294967296
    
    if shift > 0 then
        return math.floor(value * (2 ^ (-shift)))
    else
        return (value * (2 ^ (-shift))) % 4294967296
    end
end

-- Arithmetic right shift operation
function Bit32Class:arshift(value, shift)
    if math.abs(shift) >= 32 then
        return 0
    end
    
    value = value % 4294967296
    
    if shift > 0 then
        local sign = 0
        if value >= 2147483648 then
            sign = 4294967296 - (2 ^ (32 - shift))
        end
        return math.floor(value * (2 ^ (-shift))) + sign
    else
        return (value * (2 ^ (-shift))) % 4294967296
    end
end

-- Bitwise XOR operation
function Bit32Class:bxor(a, b)
    a = a % 4294967296
    b = b % 4294967296
    
    local result = 0
    local bit = 1
    
    for i = 1, 32 do
        local bitA = a % 2
        local bitB = b % 2
        
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        
        if bitA + bitB == 1 then
            result = result + bit
        end
        
        bit = bit * 2
    end
    
    return result
end

-- Create bit32 instance
local bit32 = Bit32Class.new()

return bit32