-- ReaperV4 Client Math Class
-- Clean and optimized version

local math = math

-- Clamp function
function math.clamp(value, min, max)
    if type(value) ~= "number" or type(min) ~= "number" or type(max) ~= "number" then
        return nil
    end
    
    if min > max then
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

-- Lerp function
function math.lerp(a, b, t)
    if type(a) ~= "number" or type(b) ~= "number" or type(t) ~= "number" then
        return nil
    end
    
    return a + (b - a) * t
end

-- Round function
function math.round(value, decimals)
    if type(value) ~= "number" then
        return nil
    end
    
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(value * mult + 0.5) / mult
end

-- Distance function
function math.distance(x1, y1, x2, y2)
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" then
        return nil
    end
    
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Distance 3D function
function math.distance3d(x1, y1, z1, x2, y2, z2)
    if type(x1) ~= "number" or type(y1) ~= "number" or type(z1) ~= "number" or 
       type(x2) ~= "number" or type(y2) ~= "number" or type(z2) ~= "number" then
        return nil
    end
    
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Angle between two points
function math.angleBetween(x1, y1, x2, y2)
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" then
        return nil
    end
    
    return math.atan2(y2 - y1, x2 - x1)
end

-- Normalize angle
function math.normalizeAngle(angle)
    if type(angle) ~= "number" then
        return nil
    end
    
    while angle > math.pi do
        angle = angle - 2 * math.pi
    end
    
    while angle < -math.pi do
        angle = angle + 2 * math.pi
    end
    
    return angle
end

-- Convert degrees to radians
function math.degreesToRadians(degrees)
    if type(degrees) ~= "number" then
        return nil
    end
    
    return degrees * math.pi / 180
end

-- Convert radians to degrees
function math.radiansToDegrees(radians)
    if type(radians) ~= "number" then
        return nil
    end
    
    return radians * 180 / math.pi
end

-- Random float between min and max
function math.randomFloat(min, max)
    if type(min) ~= "number" or type(max) ~= "number" then
        return nil
    end
    
    if min > max then
        return nil
    end
    
    return min + (max - min) * math.random()
end

-- Random integer between min and max
function math.randomInt(min, max)
    if type(min) ~= "number" or type(max) ~= "number" then
        return nil
    end
    
    if min > max then
        return nil
    end
    
    return math.floor(math.randomFloat(min, max + 1))
end

-- Check if number is in range
function math.inRange(value, min, max)
    if type(value) ~= "number" or type(min) ~= "number" or type(max) ~= "number" then
        return false
    end
    
    return value >= min and value <= max
end

-- Map value from one range to another
function math.map(value, inMin, inMax, outMin, outMax)
    if type(value) ~= "number" or type(inMin) ~= "number" or type(inMax) ~= "number" or 
       type(outMin) ~= "number" or type(outMax) ~= "number" then
        return nil
    end
    
    if inMin == inMax then
        return outMin
    end
    
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

-- Smooth step function
function math.smoothStep(edge0, edge1, x)
    if type(edge0) ~= "number" or type(edge1) ~= "number" or type(x) ~= "number" then
        return nil
    end
    
    local t = math.clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
end

-- Smoother step function
function math.smootherStep(edge0, edge1, x)
    if type(edge0) ~= "number" or type(edge1) ~= "number" or type(x) ~= "number" then
        return nil
    end
    
    local t = math.clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Export functions
exports("Clamp", function(value, min, max)
    return math.clamp(value, min, max)
end)

exports("Lerp", function(a, b, t)
    return math.lerp(a, b, t)
end)

exports("Round", function(value, decimals)
    return math.round(value, decimals)
end)

exports("Distance", function(x1, y1, x2, y2)
    return math.distance(x1, y1, x2, y2)
end)

exports("Distance3D", function(x1, y1, z1, x2, y2, z2)
    return math.distance3d(x1, y1, z1, x2, y2, z2)
end)

exports("AngleBetween", function(x1, y1, x2, y2)
    return math.angleBetween(x1, y1, x2, y2)
end)

exports("NormalizeAngle", function(angle)
    return math.normalizeAngle(angle)
end)

exports("DegreesToRadians", function(degrees)
    return math.degreesToRadians(degrees)
end)

exports("RadiansToDegrees", function(radians)
    return math.radiansToDegrees(radians)
end)

exports("RandomFloat", function(min, max)
    return math.randomFloat(min, max)
end)

exports("RandomInt", function(min, max)
    return math.randomInt(min, max)
end)

exports("InRange", function(value, min, max)
    return math.inRange(value, min, max)
end)

exports("Map", function(value, inMin, inMax, outMin, outMax)
    return math.map(value, inMin, inMax, outMin, outMax)
end)

exports("SmoothStep", function(edge0, edge1, x)
    return math.smoothStep(edge0, edge1, x)
end)

exports("SmootherStep", function(edge0, edge1, x)
    return math.smootherStep(edge0, edge1, x)
end)
