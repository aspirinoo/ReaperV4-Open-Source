-- ReaperV4 Bypass System
-- Clean and optimized version

local LoadResourceFile = LoadResourceFile
local load = load
local print = print
local type = type
local GetHashKey = GetHashKey
local getmetatable = getmetatable
local setmetatable = setmetatable
local pairs = pairs
local GetResourceState = GetResourceState
local CreateThread = CreateThread
local string_match = string.match
local string_gsub = string.gsub
local string_find = string.find
local string_sub = string.sub
local string_len = string.len
local string_byte = string.byte
local string_char = string.char
local table_insert = table.insert
local table_remove = table.remove
local table_copy = table.copy
local json_encode = json.encode
local json_decode = json.decode
local os_time = os.time
local math_random = math.random
local math_floor = math.floor
local math_ceil = math.ceil
local math_abs = math.abs
local math_sqrt = math.sqrt
local math_pow = math.pow
local math_sin = math.sin
local math_cos = math.cos
local math_tan = math.tan
local math_asin = math.asin
local math_acos = math.acos
local math_atan = math.atan
local math_atan2 = math.atan2
local math_log = math.log
local math_log10 = math.log10
local math_exp = math.exp
local math_deg = math.deg
local math_rad = math.rad
local math_pi = math.pi
local math_huge = math.huge
local math_mininteger = math.mininteger
local math_maxinteger = math.maxinteger
local tostring = tostring
local tonumber = tonumber
local next = next
local ipairs = ipairs
local unpack = unpack
local select = select
local pcall = pcall
local xpcall = xpcall
local error = error
local assert = assert
local rawget = rawget
local rawset = rawset
local rawequal = rawequal
local rawlen = rawlen
local getfenv = getfenv
local setfenv = setfenv
local debug_getinfo = debug.getinfo
local debug_getlocal = debug.getlocal
local debug_getupvalue = debug.getupvalue
local debug_setlocal = debug.setlocal
local debug_setupvalue = debug.setupvalue
local debug_traceback = debug.traceback
local debug_getmetatable = debug.getmetatable
local debug_setmetatable = debug.setmetatable
local debug_getregistry = debug.getregistry
local debug_getuservalue = debug.getuservalue
local debug_setuservalue = debug.setuservalue
local debug_upvalueid = debug.upvalueid
local debug_upvaluejoin = debug.upvaluejoin
local debug_sethook = debug.sethook
local debug_gethook = debug.gethook
local debug_getinfo = debug.getinfo
local debug_getlocal = debug.getlocal
local debug_getupvalue = debug.getupvalue
local debug_setlocal = debug.setlocal
local debug_setupvalue = debug.setupvalue
local debug_traceback = debug.traceback
local debug_getmetatable = debug.getmetatable
local debug_setmetatable = debug.setmetatable
local debug_getregistry = debug.getregistry
local debug_getuservalue = debug.getuservalue
local debug_setuservalue = debug.setuservalue
local debug_upvalueid = debug.upvalueid
local debug_upvaluejoin = debug.upvaluejoin
local debug_sethook = debug.sethook
local debug_gethook = debug.gethook

-- Bypass system state
local bypassState = {
    enabled = true,
    resources = {},
    hooks = {},
    detections = {},
    lastUpdate = 0
}

-- Deep copy function
function deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return setmetatable(copy, getmetatable(original))
end

-- Load resource file
function loadResourceFile(resourceName, fileName)
    if type(resourceName) ~= "string" then
        error("Resource name must be a string", 2)
    end
    
    if type(fileName) ~= "string" then
        error("File name must be a string", 2)
    end
    
    return LoadResourceFile(resourceName, fileName)
end

-- Load and execute code
function loadAndExecute(code, chunkName, environment)
    if type(code) ~= "string" then
        error("Code must be a string", 2)
    end
    
    if type(chunkName) ~= "string" then
        chunkName = "unknown"
    end
    
    if type(environment) ~= "table" then
        environment = _G
    end
    
    local func, err = load(code, chunkName, "t", environment)
    if not func then
        error(err, 2)
    end
    
    return func()
end

-- Get resource state
function getResourceState(resourceName)
    if type(resourceName) ~= "string" then
        error("Resource name must be a string", 2)
    end
    
    return GetResourceState(resourceName)
end

-- Create thread
function createThread(callback)
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    return CreateThread(callback)
end

-- String utilities
function stringMatch(str, pattern, init)
    if type(str) ~= "string" then
        error("String must be a string", 2)
    end
    
    if type(pattern) ~= "string" then
        error("Pattern must be a string", 2)
    end
    
    if type(init) ~= "number" then
        init = 1
    end
    
    return string_match(str, pattern, init)
end

function stringGsub(str, pattern, replacement, n)
    if type(str) ~= "string" then
        error("String must be a string", 2)
    end
    
    if type(pattern) ~= "string" then
        error("Pattern must be a string", 2)
    end
    
    if type(replacement) ~= "string" then
        error("Replacement must be a string", 2)
    end
    
    if type(n) ~= "number" then
        n = -1
    end
    
    return string_gsub(str, pattern, replacement, n)
end

function stringFind(str, pattern, init, plain)
    if type(str) ~= "string" then
        error("String must be a string", 2)
    end
    
    if type(pattern) ~= "string" then
        error("Pattern must be a string", 2)
    end
    
    if type(init) ~= "number" then
        init = 1
    end
    
    if type(plain) ~= "boolean" then
        plain = false
    end
    
    return string_find(str, pattern, init, plain)
end

function stringSub(str, i, j)
    if type(str) ~= "string" then
        error("String must be a string", 2)
    end
    
    if type(i) ~= "number" then
        error("Start index must be a number", 2)
    end
    
    if type(j) ~= "number" then
        j = -1
    end
    
    return string_sub(str, i, j)
end

function stringLen(str)
    if type(str) ~= "string" then
        error("String must be a string", 2)
    end
    
    return string_len(str)
end

function stringByte(str, i, j)
    if type(str) ~= "string" then
        error("String must be a string", 2)
    end
    
    if type(i) ~= "number" then
        i = 1
    end
    
    if type(j) ~= "number" then
        j = i
    end
    
    return string_byte(str, i, j)
end

function stringChar(...)
    local args = {...}
    for i, arg in ipairs(args) do
        if type(arg) ~= "number" then
            error(string_format("Argument %d must be a number", i), 2)
        end
    end
    
    return string_char(...)
end

-- Table utilities
function tableInsert(t, value, pos)
    if type(t) ~= "table" then
        error("Table must be a table", 2)
    end
    
    if type(pos) ~= "number" then
        pos = #t + 1
    end
    
    return table_insert(t, pos, value)
end

function tableRemove(t, pos)
    if type(t) ~= "table" then
        error("Table must be a table", 2)
    end
    
    if type(pos) ~= "number" then
        pos = #t
    end
    
    return table_remove(t, pos)
end

function tableCopy(t)
    if type(t) ~= "table" then
        error("Table must be a table", 2)
    end
    
    return table_copy(t)
end

-- JSON utilities
function jsonEncode(data)
    if type(data) ~= "table" then
        error("Data must be a table", 2)
    end
    
    return json_encode(data)
end

function jsonDecode(jsonData)
    if type(jsonData) ~= "string" then
        error("JSON data must be a string", 2)
    end
    
    return json_decode(jsonData)
end

-- Math utilities
function mathFloor(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_floor(x)
end

function mathCeil(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_ceil(x)
end

function mathAbs(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_abs(x)
end

function mathSqrt(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_sqrt(x)
end

function mathPow(x, y)
    if type(x) ~= "number" then
        error("Base must be a number", 2)
    end
    
    if type(y) ~= "number" then
        error("Exponent must be a number", 2)
    end
    
    return math_pow(x, y)
end

function mathSin(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_sin(x)
end

function mathCos(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_cos(x)
end

function mathTan(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_tan(x)
end

function mathAsin(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_asin(x)
end

function mathAcos(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_acos(x)
end

function mathAtan(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_atan(x)
end

function mathAtan2(y, x)
    if type(y) ~= "number" then
        error("Y must be a number", 2)
    end
    
    if type(x) ~= "number" then
        error("X must be a number", 2)
    end
    
    return math_atan2(y, x)
end

function mathLog(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_log(x)
end

function mathLog10(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_log10(x)
end

function mathExp(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_exp(x)
end

function mathDeg(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_deg(x)
end

function mathRad(x)
    if type(x) ~= "number" then
        error("Value must be a number", 2)
    end
    
    return math_rad(x)
end

-- Utility functions
function tostring(value)
    return tostring(value)
end

function tonumber(value, base)
    if type(base) ~= "number" then
        base = 10
    end
    
    return tonumber(value, base)
end

function next(t, k)
    return next(t, k)
end

function ipairs(t)
    return ipairs(t)
end

function pairs(t)
    return pairs(t)
end

function unpack(t, i, j)
    if type(i) ~= "number" then
        i = 1
    end
    
    if type(j) ~= "number" then
        j = #t
    end
    
    return unpack(t, i, j)
end

function select(n, ...)
    return select(n, ...)
end

function pcall(f, ...)
    return pcall(f, ...)
end

function xpcall(f, msgh, ...)
    return xpcall(f, msgh, ...)
end

function error(message, level)
    if type(level) ~= "number" then
        level = 1
    end
    
    return error(message, level)
end

function assert(v, message)
    if not v then
        error(message or "assertion failed!", 2)
    end
    return v
end

function rawget(t, k)
    return rawget(t, k)
end

function rawset(t, k, v)
    return rawset(t, k, v)
end

function rawequal(a, b)
    return rawequal(a, b)
end

function rawlen(t)
    return rawlen(t)
end

function getfenv(f)
    return getfenv(f)
end

function setfenv(f, env)
    return setfenv(f, env)
end

-- Debug utilities
function debugGetinfo(thread, f, what)
    return debug_getinfo(thread, f, what)
end

function debugGetlocal(thread, f, local_)
    return debug_getlocal(thread, f, local_)
end

function debugGetupvalue(f, up)
    return debug_getupvalue(f, up)
end

function debugSetlocal(thread, level, local_, value)
    return debug_setlocal(thread, level, local_, value)
end

function debugSetupvalue(f, up, value)
    return debug_setupvalue(f, up, value)
end

function debugTraceback(thread, message, level)
    return debug_traceback(thread, message, level)
end

function debugGetmetatable(object)
    return debug_getmetatable(object)
end

function debugSetmetatable(object, metatable)
    return debug_setmetatable(object, metatable)
end

function debugGetregistry()
    return debug_getregistry()
end

function debugGetuservalue(u)
    return debug_getuservalue(u)
end

function debugSetuservalue(u, value)
    return debug_setuservalue(u, value)
end

function debugUpvalueid(f, n)
    return debug_upvalueid(f, n)
end

function debugUpvaluejoin(f1, n1, f2, n2)
    return debug_upvaluejoin(f1, n1, f2, n2)
end

function debugSethook(thread, hook, mask, count)
    return debug_sethook(thread, hook, mask, count)
end

function debugGethook(thread)
    return debug_gethook(thread)
end

-- Bypass system functions
function enableBypass()
    bypassState.enabled = true
end

function disableBypass()
    bypassState.enabled = false
end

function isBypassEnabled()
    return bypassState.enabled
end

function addBypassHook(hookName, callback)
    if type(hookName) ~= "string" then
        error("Hook name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    bypassState.hooks[hookName] = callback
end

function removeBypassHook(hookName)
    if type(hookName) ~= "string" then
        error("Hook name must be a string", 2)
    end
    
    bypassState.hooks[hookName] = nil
end

function getBypassHook(hookName)
    if type(hookName) ~= "string" then
        error("Hook name must be a string", 2)
    end
    
    return bypassState.hooks[hookName]
end

function getAllBypassHooks()
    return table_copy(bypassState.hooks)
end

function addBypassDetection(detectionName, callback)
    if type(detectionName) ~= "string" then
        error("Detection name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    bypassState.detections[detectionName] = callback
end

function removeBypassDetection(detectionName)
    if type(detectionName) ~= "string" then
        error("Detection name must be a string", 2)
    end
    
    bypassState.detections[detectionName] = nil
end

function getBypassDetection(detectionName)
    if type(detectionName) ~= "string" then
        error("Detection name must be a string", 2)
    end
    
    return bypassState.detections[detectionName]
end

function getAllBypassDetections()
    return table_copy(bypassState.detections)
end

function getBypassState()
    return {
        enabled = bypassState.enabled,
        resources = table_copy(bypassState.resources),
        hooks = table_copy(bypassState.hooks),
        detections = table_copy(bypassState.detections),
        lastUpdate = bypassState.lastUpdate
    }
end

function updateBypassState()
    bypassState.lastUpdate = os_time()
end

-- Export functions
exports("LoadResourceFile", function(resourceName, fileName)
    return loadResourceFile(resourceName, fileName)
end)

exports("LoadAndExecute", function(code, chunkName, environment)
    return loadAndExecute(code, chunkName, environment)
end)

exports("GetResourceState", function(resourceName)
    return getResourceState(resourceName)
end)

exports("CreateThread", function(callback)
    return createThread(callback)
end)

exports("StringMatch", function(str, pattern, init)
    return stringMatch(str, pattern, init)
end)

exports("StringGsub", function(str, pattern, replacement, n)
    return stringGsub(str, pattern, replacement, n)
end)

exports("StringFind", function(str, pattern, init, plain)
    return stringFind(str, pattern, init, plain)
end)

exports("StringSub", function(str, i, j)
    return stringSub(str, i, j)
end)

exports("StringLen", function(str)
    return stringLen(str)
end)

exports("StringByte", function(str, i, j)
    return stringByte(str, i, j)
end)

exports("StringChar", function(...)
    return stringChar(...)
end)

exports("TableInsert", function(t, value, pos)
    return tableInsert(t, value, pos)
end)

exports("TableRemove", function(t, pos)
    return tableRemove(t, pos)
end)

exports("TableCopy", function(t)
    return tableCopy(t)
end)

exports("JsonEncode", function(data)
    return jsonEncode(data)
end)

exports("JsonDecode", function(jsonData)
    return jsonDecode(jsonData)
end)

exports("MathFloor", function(x)
    return mathFloor(x)
end)

exports("MathCeil", function(x)
    return mathCeil(x)
end)

exports("MathAbs", function(x)
    return mathAbs(x)
end)

exports("MathSqrt", function(x)
    return mathSqrt(x)
end)

exports("MathPow", function(x, y)
    return mathPow(x, y)
end)

exports("MathSin", function(x)
    return mathSin(x)
end)

exports("MathCos", function(x)
    return mathCos(x)
end)

exports("MathTan", function(x)
    return mathTan(x)
end)

exports("MathAsin", function(x)
    return mathAsin(x)
end)

exports("MathAcos", function(x)
    return mathAcos(x)
end)

exports("MathAtan", function(x)
    return mathAtan(x)
end)

exports("MathAtan2", function(y, x)
    return mathAtan2(y, x)
end)

exports("MathLog", function(x)
    return mathLog(x)
end)

exports("MathLog10", function(x)
    return mathLog10(x)
end)

exports("MathExp", function(x)
    return mathExp(x)
end)

exports("MathDeg", function(x)
    return mathDeg(x)
end)

exports("MathRad", function(x)
    return mathRad(x)
end)

exports("Tostring", function(value)
    return tostring(value)
end)

exports("Tonumber", function(value, base)
    return tonumber(value, base)
end)

exports("Next", function(t, k)
    return next(t, k)
end)

exports("Ipairs", function(t)
    return ipairs(t)
end)

exports("Pairs", function(t)
    return pairs(t)
end)

exports("Unpack", function(t, i, j)
    return unpack(t, i, j)
end)

exports("Select", function(n, ...)
    return select(n, ...)
end)

exports("Pcall", function(f, ...)
    return pcall(f, ...)
end)

exports("Xpcall", function(f, msgh, ...)
    return xpcall(f, msgh, ...)
end)

exports("Error", function(message, level)
    return error(message, level)
end)

exports("Assert", function(v, message)
    return assert(v, message)
end)

exports("Rawget", function(t, k)
    return rawget(t, k)
end)

exports("Rawset", function(t, k, v)
    return rawset(t, k, v)
end)

exports("Rawequal", function(a, b)
    return rawequal(a, b)
end)

exports("Rawlen", function(t)
    return rawlen(t)
end)

exports("Getfenv", function(f)
    return getfenv(f)
end)

exports("Setfenv", function(f, env)
    return setfenv(f, env)
end)

exports("DebugGetinfo", function(thread, f, what)
    return debugGetinfo(thread, f, what)
end)

exports("DebugGetlocal", function(thread, f, local_)
    return debugGetlocal(thread, f, local_)
end)

exports("DebugGetupvalue", function(f, up)
    return debugGetupvalue(f, up)
end)

exports("DebugSetlocal", function(thread, level, local_, value)
    return debugSetlocal(thread, level, local_, value)
end)

exports("DebugSetupvalue", function(f, up, value)
    return debugSetupvalue(f, up, value)
end)

exports("DebugTraceback", function(thread, message, level)
    return debugTraceback(thread, message, level)
end)

exports("DebugGetmetatable", function(object)
    return debugGetmetatable(object)
end)

exports("DebugSetmetatable", function(object, metatable)
    return debugSetmetatable(object, metatable)
end)

exports("DebugGetregistry", function()
    return debugGetregistry()
end)

exports("DebugGetuservalue", function(u)
    return debugGetuservalue(u)
end)

exports("DebugSetuservalue", function(u, value)
    return debugSetuservalue(u, value)
end)

exports("DebugUpvalueid", function(f, n)
    return debugUpvalueid(f, n)
end)

exports("DebugUpvaluejoin", function(f1, n1, f2, n2)
    return debugUpvaluejoin(f1, n1, f2, n2)
end)

exports("DebugSethook", function(thread, hook, mask, count)
    return debugSethook(thread, hook, mask, count)
end)

exports("DebugGethook", function(thread)
    return debugGethook(thread)
end)

exports("EnableBypass", function()
    return enableBypass()
end)

exports("DisableBypass", function()
    return disableBypass()
end)

exports("IsBypassEnabled", function()
    return isBypassEnabled()
end)

exports("AddBypassHook", function(hookName, callback)
    return addBypassHook(hookName, callback)
end)

exports("RemoveBypassHook", function(hookName)
    return removeBypassHook(hookName)
end)

exports("GetBypassHook", function(hookName)
    return getBypassHook(hookName)
end)

exports("GetAllBypassHooks", function()
    return getAllBypassHooks()
end)

exports("AddBypassDetection", function(detectionName, callback)
    return addBypassDetection(detectionName, callback)
end)

exports("RemoveBypassDetection", function(detectionName)
    return removeBypassDetection(detectionName)
end)

exports("GetBypassDetection", function(detectionName)
    return getBypassDetection(detectionName)
end)

exports("GetAllBypassDetections", function()
    return getAllBypassDetections()
end)

exports("GetBypassState", function()
    return getBypassState()
end)

exports("UpdateBypassState", function()
    return updateBypassState()
end)
