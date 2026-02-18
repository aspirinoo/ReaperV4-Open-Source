-- ReaperV4 Class System
-- Clean and optimized version

-- Type checking function
local function checkType(name, value, expectedType)
    local actualType = type(value)
    if actualType ~= expectedType then
        local fieldType = type(name) == "string" and "field" or "argument"
        error(string.format("expected %s %s to have type '%s' (received %s)", 
            fieldType, name, expectedType, actualType), 3)
    end
    
    -- Additional check for table type
    if expectedType == "table" then
        local tableType = table.type(value)
        if tableType ~= "hash" then
            error(string.format("expected argument %s to have table.type 'hash' (received %s)", 
                name, tableType), 3)
        end
    end
    
    return true
end

-- Class creation function
function class(className)
    local Class = {}
    Class.__name = className
    Class.__index = Class
    
    -- Constructor
    function Class:new(...)
        local instance = {}
        setmetatable(instance, Class)
        
        if Class.constructor then
            Class.constructor(instance, ...)
        end
        
        return instance
    end
    
    -- Inheritance
    function Class:extends(parentClass)
        local Child = {}
        Child.__name = Class.__name
        Child.__index = Child
        Child.__parent = Class
        
        -- Copy parent methods
        for key, value in pairs(Class) do
            if key ~= "__index" and key ~= "__name" and key ~= "__parent" then
                Child[key] = value
            end
        end
        
        -- Set up inheritance chain
        setmetatable(Child, {__index = function(t, k)
            local result = Class[k]
            if result then
                return result
            end
            return parentClass[k]
        end})
        
        return Child
    end
    
    -- Method binding
    function Class:bind(methodName, func)
        if type(func) ~= "function" then
            error("expected function for method binding", 2)
        end
        
        Class[methodName] = func
    end
    
    -- Property getter/setter
    function Class:property(name, getter, setter)
        if getter and type(getter) ~= "function" then
            error("getter must be a function", 2)
        end
        
        if setter and type(setter) ~= "function" then
            error("setter must be a function", 2)
        end
        
        -- Create property descriptor
        local descriptor = {
            get = getter,
            set = setter,
            enumerable = true,
            configurable = true
        }
        
        -- Store property descriptor
        if not Class.__properties then
            Class.__properties = {}
        end
        Class.__properties[name] = descriptor
    end
    
    -- Static methods
    function Class:static(methodName, func)
        if type(func) ~= "function" then
            error("static method must be a function", 2)
        end
        
        Class[methodName] = func
    end
    
    -- Instance methods
    function Class:method(methodName, func)
        if type(func) ~= "function" then
            error("method must be a function", 2)
        end
        
        Class[methodName] = func
    end
    
    -- Event system
    function Class:on(eventName, callback)
        if type(eventName) ~= "string" then
            error("event name must be a string", 2)
        end
        
        if type(callback) ~= "function" then
            error("callback must be a function", 2)
        end
        
        if not Class.__events then
            Class.__events = {}
        end
        
        if not Class.__events[eventName] then
            Class.__events[eventName] = {}
        end
        
        table.insert(Class.__events[eventName], callback)
    end
    
    function Class:emit(eventName, ...)
        if not Class.__events or not Class.__events[eventName] then
            return
        end
        
        for _, callback in pairs(Class.__events[eventName]) do
            callback(...)
        end
    end
    
    -- Validation
    function Class:validate(instance)
        if not Class.__validators then
            return true
        end
        
        for fieldName, validator in pairs(Class.__validators) do
            if not validator(instance[fieldName]) then
                return false, string.format("validation failed for field: %s", fieldName)
            end
        end
        
        return true
    end
    
    function Class:validator(fieldName, validator)
        if type(validator) ~= "function" then
            error("validator must be a function", 2)
        end
        
        if not Class.__validators then
            Class.__validators = {}
        end
        
        Class.__validators[fieldName] = validator
    end
    
    -- Serialization
    function Class:serialize(instance)
        local data = {}
        
        for key, value in pairs(instance) do
            if key:sub(1, 2) ~= "__" then
                if type(value) == "table" then
                    data[key] = table.copy(value)
                else
                    data[key] = value
                end
            end
        end
        
        return data
    end
    
    function Class:deserialize(data)
        local instance = Class:new()
        
        for key, value in pairs(data) do
            instance[key] = value
        end
        
        return instance
    end
    
    -- Utility methods
    function Class:isInstance(obj)
        return type(obj) == "table" and getmetatable(obj) == Class
    end
    
    function Class:getName()
        return Class.__name
    end
    
    function Class:getParent()
        return Class.__parent
    end
    
    -- Metatable setup
    setmetatable(Class, {
        __call = function(self, ...)
            return self:new(...)
        end
    })
    
    return Class
end

-- Utility functions
function table.copy(t)
    local copy = {}
    for key, value in pairs(t) do
        if type(value) == "table" then
            copy[key] = table.copy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function table.merge(t1, t2)
    local merged = table.copy(t1)
    for key, value in pairs(t2) do
        merged[key] = value
    end
    return merged
end

function table.filter(t, predicate)
    local filtered = {}
    for key, value in pairs(t) do
        if predicate(value, key) then
            filtered[key] = value
        end
    end
    return filtered
end

function table.map(t, transform)
    local mapped = {}
    for key, value in pairs(t) do
        mapped[key] = transform(value, key)
    end
    return mapped
end

function table.numbers_to_string(t)
    local converted = {}
    for key, value in pairs(t) do
        if type(value) == "number" then
            converted[key] = tostring(value)
        elseif type(value) == "table" then
            converted[key] = table.numbers_to_string(value)
        else
            converted[key] = value
        end
    end
    return converted
end

-- Export the class function
return class
