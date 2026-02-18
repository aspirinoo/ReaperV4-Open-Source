-- ReaperV4 Imports
-- This file is loaded into every resource on resource start. You can use Reaper API functions inside of this file to add extra security to scripts

-- Reaper API functions
local ReaperAPI = {
    -- Security functions
    Security = {
        Hash = function(input)
            return exports["reaper"]:Hash(input)
        end,
        Encrypt = function(data)
            return exports["reaper"]:Encrypt(data)
        end,
        Decrypt = function(encryptedData)
            return exports["reaper"]:Decrypt(encryptedData)
        end,
        GenerateUUID = function()
            return exports["reaper"]:GenerateUUID()
        end,
        AddDetectionHook = function(detectionType, callback)
            return exports["reaper"]:AddDetectionHook(detectionType, callback)
        end,
        ValidateInput = function(input, inputType)
            return exports["reaper"]:ValidateInput(input, inputType)
        end,
        SanitizeString = function(str)
            return exports["reaper"]:SanitizeString(str)
        end,
        GenerateToken = function(length)
            return exports["reaper"]:GenerateToken(length)
        end
    },
    
    -- Logger functions
    Logger = {
        Log = function(message, level)
            return exports["reaper"]:Log(message, level)
        end,
        Debug = function(message)
            return exports["reaper"]:Log(message, "debug")
        end,
        Info = function(message)
            return exports["reaper"]:Log(message, "info")
        end,
        Warn = function(message)
            return exports["reaper"]:Log(message, "warn")
        end,
        Error = function(message)
            return exports["reaper"]:Log(message, "error")
        end
    },
    
    -- Player functions
    Player = {
        GetName = function(source)
            return exports["reaper"]:GetPlayerName(source)
        end,
        GetIdentifiers = function(source)
            return exports["reaper"]:GetPlayerIdentifiers(source)
        end,
        GetEndpoint = function(source)
            return exports["reaper"]:GetPlayerEndpoint(source)
        end,
        GetPing = function(source)
            return exports["reaper"]:GetPlayerPing(source)
        end,
        GetPosition = function(source)
            return exports["reaper"]:GetPlayerPosition(source)
        end,
        GetHealth = function(source)
            return exports["reaper"]:GetPlayerHealth(source)
        end,
        GetArmor = function(source)
            return exports["reaper"]:GetPlayerArmor(source)
        end,
        GetData = function(source)
            return exports["reaper"]:GetPlayerData(source)
        end,
        GetDataAsJSON = function(source)
            return exports["reaper"]:GetPlayerDataAsJSON(source)
        end
    },
    
    -- Cache functions
    Cache = {
        Set = function(key, value, ttl)
            return exports["reaper"]:SetCache(key, value, ttl)
        end,
        Get = function(key, defaultValue)
            return exports["reaper"]:GetCache(key, defaultValue)
        end,
        Remove = function(key)
            return exports["reaper"]:RemoveCache(key)
        end,
        Has = function(key)
            return exports["reaper"]:HasCache(key)
        end,
        Clear = function()
            return exports["reaper"]:ClearCache()
        end,
        GetKeys = function()
            return exports["reaper"]:GetCacheKeys()
        end,
        GetSize = function()
            return exports["reaper"]:GetCacheSize()
        end,
        GetStats = function()
            return exports["reaper"]:GetCacheStats()
        end,
        SetMaxSize = function(maxSize)
            return exports["reaper"]:SetCacheMaxSize(maxSize)
        end,
        GetMaxSize = function()
            return exports["reaper"]:GetCacheMaxSize()
        end,
        Cleanup = function()
            return exports["reaper"]:CleanupCache()
        end,
        CleanupLRU = function()
            return exports["reaper"]:CleanupLRUCache()
        end,
        ToJSON = function()
            return exports["reaper"]:CacheToJSON()
        end,
        FromJSON = function(jsonData)
            return exports["reaper"]:CacheFromJSON(jsonData)
        end
    },
    
    -- Settings functions
    Settings = {
        Set = function(key, value, replicated)
            return exports["reaper"]:SetSetting(key, value, replicated)
        end,
        Get = function(key, defaultValue)
            return exports["reaper"]:GetSetting(key, defaultValue)
        end,
        SetDefault = function(key, value)
            return exports["reaper"]:SetDefault(key, value)
        end,
        GetDefault = function(key)
            return exports["reaper"]:GetDefault(key)
        end,
        SetValidator = function(key, validator)
            return exports["reaper"]:SetValidator(key, validator)
        end,
        GetValidator = function(key)
            return exports["reaper"]:GetValidator(key)
        end,
        AddCallback = function(key, callback)
            return exports["reaper"]:AddCallback(key, callback)
        end,
        RemoveCallback = function(key, callback)
            return exports["reaper"]:RemoveCallback(key, callback)
        end,
        GetAll = function()
            return exports["reaper"]:GetAllSettings()
        end,
        GetAllDefaults = function()
            return exports["reaper"]:GetAllDefaults()
        end,
        LoadFromFile = function(filePath)
            return exports["reaper"]:LoadFromFile(filePath)
        end,
        SaveToFile = function(filePath)
            return exports["reaper"]:SaveToFile(filePath)
        end,
        Reset = function(key)
            return exports["reaper"]:ResetSetting(key)
        end,
        ResetAll = function()
            return exports["reaper"]:ResetAllSettings()
        end,
        Exists = function(key)
            return exports["reaper"]:SettingExists(key)
        end,
        Remove = function(key)
            return exports["reaper"]:RemoveSetting(key)
        end,
        ToJSON = function()
            return exports["reaper"]:SettingsToJSON()
        end,
        FromJSON = function(jsonData)
            return exports["reaper"]:SettingsFromJSON(jsonData)
        end
    },
    
    -- Command functions
    Command = {
        Register = function(name, callback, permission, help, usage, example)
            return exports["reaper"]:RegisterCommand(name, callback, permission, help, usage, example)
        end,
        Execute = function(source, name, args)
            return exports["reaper"]:ExecuteCommand(source, name, args)
        end,
        GetHelp = function(name)
            return exports["reaper"]:GetCommandHelp(name)
        end,
        GetUsage = function(name)
            return exports["reaper"]:GetCommandUsage(name)
        end,
        GetExample = function(name)
            return exports["reaper"]:GetCommandExample(name)
        end,
        GetCommands = function()
            return exports["reaper"]:GetCommands()
        end,
        GetList = function()
            return exports["reaper"]:GetCommandList()
        end,
        GetListAsJSON = function()
            return exports["reaper"]:GetCommandListAsJSON()
        end,
        Remove = function(name)
            return exports["reaper"]:RemoveCommand(name)
        end
    },
    
    -- HTTP functions
    HTTP = {
        AddRoute = function(method, path, handler, middleware)
            return exports["reaper"]:AddRoute(method, path, handler, middleware)
        end,
        AddMiddleware = function(name, middleware)
            return exports["reaper"]:AddMiddleware(name, middleware)
        end,
        SetCORS = function(enabled, origins, methods, headers)
            return exports["reaper"]:SetCORS(enabled, origins, methods, headers)
        end,
        SetRateLimit = function(enabled, maxRequests, windowMs)
            return exports["reaper"]:SetRateLimit(enabled, maxRequests, windowMs)
        end,
        SetSecurity = function(enabled, maxBodySize, allowedMethods, blockedIPs)
            return exports["reaper"]:SetSecurity(enabled, maxBodySize, allowedMethods, blockedIPs)
        end,
        GetRoutes = function()
            return exports["reaper"]:GetRoutes()
        end,
        GetMiddleware = function()
            return exports["reaper"]:GetMiddleware()
        end,
        GetCORS = function()
            return exports["reaper"]:GetCORS()
        end,
        GetRateLimit = function()
            return exports["reaper"]:GetRateLimit()
        end,
        GetSecurity = function()
            return exports["reaper"]:GetSecurity()
        end
    },
    
    -- RPC functions
    RPC = {
        Register = function(methodName, callback)
            return exports["reaper"]:RegisterRPC(methodName, callback)
        end,
        Call = function(methodName, ...)
            return exports["reaper"]:CallRPC(methodName, ...)
        end,
        OnNet = function(eventName, callback)
            return exports["reaper"]:OnNetRPC(eventName, callback)
        end,
        Emit = function(eventName, ...)
            return exports["reaper"]:EmitRPC(eventName, ...)
        end,
        Await = function(methodName, ...)
            return exports["reaper"]:AwaitRPC(methodName, ...)
        end
    },
    
    -- NUI functions
    NUI = {
        SendMessage = function(data)
            return exports["reaper"]:SendNUIMessage(data)
        end,
        OnCallback = function(callbackName, callback)
            return exports["reaper"]:OnNUICallback(callbackName, callback)
        end,
        SetFocus = function(hasFocus, hasCursor)
            return exports["reaper"]:SetNUIFocus(hasFocus, hasCursor)
        end,
        ClipScreen = function()
            return exports["reaper"]:ClipScreen()
        end,
        Screenshot = function()
            return exports["reaper"]:Screenshot()
        end,
        GetOCRText = function()
            return exports["reaper"]:GetOCRText()
        end,
        CreateDUI = function(url, width, height)
            return exports["reaper"]:CreateDUI(url, width, height)
        end,
        SendDUIMessage = function(message)
            return exports["reaper"]:SendDUIMessage(message)
        end,
        IsDUIAvailable = function()
            return exports["reaper"]:IsDUIAvailable()
        end
    },
    
    -- Weapons functions
    Weapons = {
        GetHash = function(weaponName)
            return exports["reaper"]:GetWeaponHash(weaponName)
        end,
        GetDamageType = function(weaponHash)
            return exports["reaper"]:GetWeaponDamageType(weaponHash)
        end,
        GetDamageModifier = function(weaponHash)
            return exports["reaper"]:GetWeaponDamageModifier(weaponHash)
        end,
        GetMaxRange = function(weaponHash)
            return exports["reaper"]:GetWeaponMaxRange(weaponHash)
        end,
        GetLockonDistance = function(weaponHash)
            return exports["reaper"]:GetWeaponLockonDistance(weaponHash)
        end,
        GetAmmo = function(weaponHash)
            return exports["reaper"]:GetWeaponAmmo(weaponHash)
        end,
        HasComponent = function(weaponHash, componentHash)
            return exports["reaper"]:HasWeaponComponent(weaponHash, componentHash)
        end,
        GetLabel = function(weaponHash)
            return exports["reaper"]:GetWeaponLabel(weaponHash)
        end,
        GetSelected = function()
            return exports["reaper"]:GetSelectedWeapon()
        end,
        IsExplosive = function(weaponHash)
            return exports["reaper"]:IsExplosiveWeapon(weaponHash)
        end,
        GetInfo = function(weaponHash)
            return exports["reaper"]:GetWeaponInfo(weaponHash)
        end,
        GetByName = function(weaponName)
            return exports["reaper"]:GetWeaponByName(weaponName)
        end,
        GetStats = function()
            return exports["reaper"]:GetWeaponStats()
        end
    },
    
    -- Math functions
    Math = {
        Clamp = function(value, min, max)
            return exports["reaper"]:Clamp(value, min, max)
        end,
        Lerp = function(a, b, t)
            return exports["reaper"]:Lerp(a, b, t)
        end,
        Round = function(value, decimals)
            return exports["reaper"]:Round(value, decimals)
        end,
        Distance = function(x1, y1, x2, y2)
            return exports["reaper"]:Distance(x1, y1, x2, y2)
        end,
        Distance3D = function(x1, y1, z1, x2, y2, z2)
            return exports["reaper"]:Distance3D(x1, y1, z1, x2, y2, z2)
        end,
        AngleBetween = function(x1, y1, x2, y2)
            return exports["reaper"]:AngleBetween(x1, y1, x2, y2)
        end,
        NormalizeAngle = function(angle)
            return exports["reaper"]:NormalizeAngle(angle)
        end,
        DegreesToRadians = function(degrees)
            return exports["reaper"]:DegreesToRadians(degrees)
        end,
        RadiansToDegrees = function(radians)
            return exports["reaper"]:RadiansToDegrees(radians)
        end,
        RandomFloat = function(min, max)
            return exports["reaper"]:RandomFloat(min, max)
        end,
        RandomInt = function(min, max)
            return exports["reaper"]:RandomInt(min, max)
        end,
        InRange = function(value, min, max)
            return exports["reaper"]:InRange(value, min, max)
        end,
        Map = function(value, inMin, inMax, outMin, outMax)
            return exports["reaper"]:Map(value, inMin, inMax, outMin, outMax)
        end,
        SmoothStep = function(edge0, edge1, x)
            return exports["reaper"]:SmoothStep(edge0, edge1, x)
        end,
        SmootherStep = function(edge0, edge1, x)
            return exports["reaper"]:SmootherStep(edge0, edge1, x)
        end
    },
    
    -- String functions
    String = {
        Starts = function(str, prefix)
            return exports["reaper"]:Starts(str, prefix)
        end,
        Ends = function(str, suffix)
            return exports["reaper"]:Ends(str, suffix)
        end,
        Split = function(str, delimiter)
            return exports["reaper"]:Split(str, delimiter)
        end,
        Join = function(tbl, delimiter)
            return exports["reaper"]:Join(tbl, delimiter)
        end,
        Trim = function(str)
            return exports["reaper"]:Trim(str)
        end,
        Capitalize = function(str)
            return exports["reaper"]:Capitalize(str)
        end,
        TitleCase = function(str)
            return exports["reaper"]:TitleCase(str)
        end,
        Contains = function(str, substring)
            return exports["reaper"]:Contains(str, substring)
        end,
        Count = function(str, substring)
            return exports["reaper"]:Count(str, substring)
        end,
        ReplaceAll = function(str, old, new)
            return exports["reaper"]:ReplaceAll(str, old, new)
        end,
        Pad = function(str, length, padChar)
            return exports["reaper"]:Pad(str, length, padChar)
        end,
        PadLeft = function(str, length, padChar)
            return exports["reaper"]:PadLeft(str, length, padChar)
        end,
        Reverse = function(str)
            return exports["reaper"]:Reverse(str)
        end,
        IsEmpty = function(str)
            return exports["reaper"]:IsEmpty(str)
        end,
        Random = function(length, charset)
            return exports["reaper"]:Random(length, charset)
        end,
        FormatArgs = function(str, ...)
            return exports["reaper"]:FormatArgs(str, ...)
        end
    }
}

-- Make Reaper API available globally
_G.Reaper = ReaperAPI

-- Export Reaper API
return ReaperAPI
