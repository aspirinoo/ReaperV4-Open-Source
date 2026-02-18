-- ReaperV4 Server HTTP Class
-- Clean and optimized version

local class = class
local GetConvar = GetConvar
local SetHttpHandler = SetHttpHandler
local type = type
local tostring = tostring
local string_format = string.format
local string_gsub = string.gsub
local string_find = string.find
local string_sub = string.sub
local table_insert = table.insert
local table_remove = table.remove
local table_copy = table.copy
local json_encode = json.encode
local json_decode = json.decode
local os_time = os.time
local math_random = math.random

-- HTTP class definition
local HTTPClass = class("HTTP")

-- Constructor
function HTTPClass:constructor()
    self.handlers = {}
    self.middleware = {}
    self.routes = {}
    self.cors = {
        enabled = true,
        origins = {"*"},
        methods = {"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        headers = {"Content-Type", "Authorization", "X-Requested-With"}
    }
    self.rateLimit = {
        enabled = true,
        maxRequests = 100,
        windowMs = 60000, -- 1 minute
        requests = {}
    }
    self.security = {
        enabled = true,
        maxBodySize = 1024 * 1024, -- 1MB
        allowedMethods = {"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        blockedIPs = {}
    }
end

-- Set HTTP handler
function HTTPClass:setHandler(handler)
    if type(handler) ~= "function" then
        error("Handler must be a function", 2)
    end
    
    SetHttpHandler(handler)
end

-- Add route
function HTTPClass:addRoute(method, path, handler, middleware)
    if type(method) ~= "string" then
        error("Method must be a string", 2)
    end
    
    if type(path) ~= "string" then
        error("Path must be a string", 2)
    end
    
    if type(handler) ~= "function" then
        error("Handler must be a function", 2)
    end
    
    if not self.routes[method] then
        self.routes[method] = {}
    end
    
    self.routes[method][path] = {
        handler = handler,
        middleware = middleware or {}
    }
end

-- Add middleware
function HTTPClass:addMiddleware(name, middleware)
    if type(name) ~= "string" then
        error("Middleware name must be a string", 2)
    end
    
    if type(middleware) ~= "function" then
        error("Middleware must be a function", 2)
    end
    
    self.middleware[name] = middleware
end

-- Handle request
function HTTPClass:handleRequest(req, res)
    -- Check rate limit
    if self.rateLimit.enabled then
        if not self:checkRateLimit(req) then
            res.writeHead(429, {"Content-Type": "application/json"})
            res.write(json_encode({error = "Too Many Requests"}))
            res.send()
            return
        end
    end
    
    -- Check security
    if self.security.enabled then
        if not self:checkSecurity(req) then
            res.writeHead(403, {"Content-Type": "application/json"})
            res.write(json_encode({error = "Forbidden"}))
            res.send()
            return
        end
    end
    
    -- Handle CORS
    if self.cors.enabled then
        self:handleCORS(req, res)
    end
    
    -- Find route
    local route = self:findRoute(req.method, req.path)
    if not route then
        res.writeHead(404, {"Content-Type": "application/json"})
        res.write(json_encode({error = "Not Found"}))
        res.send()
        return
    end
    
    -- Execute middleware
    for _, middlewareName in pairs(route.middleware) do
        local middleware = self.middleware[middlewareName]
        if middleware then
            local success, result = pcall(middleware, req, res)
            if not success then
                res.writeHead(500, {"Content-Type": "application/json"})
                res.write(json_encode({error = "Internal Server Error"}))
                res.send()
                return
            end
            if result == false then
                return -- Middleware blocked the request
        end
      end
    end
    
    -- Execute handler
    local success, result = pcall(route.handler, req, res)
    if not success then
        res.writeHead(500, {"Content-Type": "application/json"})
        res.write(json_encode({error = "Internal Server Error"}))
        res.send()
        return
    end
end

-- Find route
function HTTPClass:findRoute(method, path)
    if not self.routes[method] then
        return nil
    end
    
    -- Exact match
    if self.routes[method][path] then
        return self.routes[method][path]
    end
    
    -- Pattern match
    for routePath, route in pairs(self.routes[method]) do
        if self:matchPath(path, routePath) then
            return route
        end
      end
    
    return nil
end

-- Match path pattern
function HTTPClass:matchPath(path, pattern)
    -- Convert pattern to regex
    local regex = string_gsub(pattern, ":[^/]+", "([^/]+)")
    regex = string_gsub(regex, "%*", ".*")
    regex = "^" .. regex .. "$"
    
    return string_find(path, regex) ~= nil
end

-- Check rate limit
function HTTPClass:checkRateLimit(req)
    local ip = req.headers["x-forwarded-for"] or req.headers["x-real-ip"] or "unknown"
    local now = os_time()
    local windowStart = now - self.rateLimit.windowMs
    
    -- Clean old requests
    if self.rateLimit.requests[ip] then
        for i = #self.rateLimit.requests[ip], 1, -1 do
            if self.rateLimit.requests[ip][i] < windowStart then
                table_remove(self.rateLimit.requests[ip], i)
            end
        end
    else
        self.rateLimit.requests[ip] = {}
    end
    
    -- Check if limit exceeded
    if #self.rateLimit.requests[ip] >= self.rateLimit.maxRequests then
        return false
    end
    
    -- Add current request
    table_insert(self.rateLimit.requests[ip], now)
    return true
end

-- Check security
function HTTPClass:checkSecurity(req)
    -- Check blocked IPs
    local ip = req.headers["x-forwarded-for"] or req.headers["x-real-ip"] or "unknown"
    if self.security.blockedIPs[ip] then
        return false
    end
    
    -- Check method
    local allowed = false
    for _, method in pairs(self.security.allowedMethods) do
        if req.method == method then
            allowed = true
            break
        end
    end
    if not allowed then
        return false
    end
    
    -- Check body size
    if req.body and #req.body > self.security.maxBodySize then
        return false
    end
    
    return true
end

-- Handle CORS
function HTTPClass:handleCORS(req, res)
    local origin = req.headers.origin
    if origin and self:isOriginAllowed(origin) then
        res.setHeader("Access-Control-Allow-Origin", origin)
    end
    
    res.setHeader("Access-Control-Allow-Methods", table.concat(self.cors.methods, ", "))
    res.setHeader("Access-Control-Allow-Headers", table.concat(self.cors.headers, ", "))
    res.setHeader("Access-Control-Allow-Credentials", "true")
    
    if req.method == "OPTIONS" then
        res.writeHead(200)
        res.send()
        return true
    end
    
    return false
end

-- Check if origin is allowed
function HTTPClass:isOriginAllowed(origin)
    for _, allowedOrigin in pairs(self.cors.origins) do
        if allowedOrigin == "*" or allowedOrigin == origin then
            return true
        end
    end
    return false
end

-- Set CORS
function HTTPClass:setCORS(enabled, origins, methods, headers)
    self.cors.enabled = enabled
    if origins then
        self.cors.origins = origins
    end
    if methods then
        self.cors.methods = methods
    end
    if headers then
        self.cors.headers = headers
    end
end

-- Set rate limit
function HTTPClass:setRateLimit(enabled, maxRequests, windowMs)
    self.rateLimit.enabled = enabled
    if maxRequests then
        self.rateLimit.maxRequests = maxRequests
    end
    if windowMs then
        self.rateLimit.windowMs = windowMs
    end
end

-- Set security
function HTTPClass:setSecurity(enabled, maxBodySize, allowedMethods, blockedIPs)
    self.security.enabled = enabled
    if maxBodySize then
        self.security.maxBodySize = maxBodySize
    end
    if allowedMethods then
        self.security.allowedMethods = allowedMethods
    end
    if blockedIPs then
        self.security.blockedIPs = blockedIPs
    end
end

-- Get routes
function HTTPClass:getRoutes()
    return table_copy(self.routes)
end

-- Get middleware
function HTTPClass:getMiddleware()
    return table_copy(self.middleware)
end

-- Get CORS settings
function HTTPClass:getCORS()
    return table_copy(self.cors)
end

-- Get rate limit settings
function HTTPClass:getRateLimit()
    return table_copy(self.rateLimit)
end

-- Get security settings
function HTTPClass:getSecurity()
    return table_copy(self.security)
end

-- Create HTTP instance
HTTP = HTTPClass.new()

-- Set default handler
HTTP:setHandler(function(req, res)
    HTTP:handleRequest(req, res)
end)

-- Export functions
exports("AddRoute", function(method, path, handler, middleware)
    return HTTP:addRoute(method, path, handler, middleware)
end)

exports("AddMiddleware", function(name, middleware)
    return HTTP:addMiddleware(name, middleware)
end)

exports("SetCORS", function(enabled, origins, methods, headers)
    return HTTP:setCORS(enabled, origins, methods, headers)
end)

exports("SetRateLimit", function(enabled, maxRequests, windowMs)
    return HTTP:setRateLimit(enabled, maxRequests, windowMs)
end)

exports("SetSecurity", function(enabled, maxBodySize, allowedMethods, blockedIPs)
    return HTTP:setSecurity(enabled, maxBodySize, allowedMethods, blockedIPs)
end)

exports("GetRoutes", function()
    return HTTP:getRoutes()
end)

exports("GetMiddleware", function()
    return HTTP:getMiddleware()
end)

exports("GetCORS", function()
    return HTTP:getCORS()
end)

exports("GetRateLimit", function()
    return HTTP:getRateLimit()
end)

exports("GetSecurity", function()
    return HTTP:getSecurity()
end)
