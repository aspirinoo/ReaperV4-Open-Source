-- ReaperV4 Server Features Class
-- Clean and optimized version

local class = class
local json_decode = json.decode
local string_format = string.format
local Wait = Wait

-- Features class definition
local FeaturesClass = class("Features")

-- Constructor
function FeaturesClass:constructor()
    self.features = {}
    self.load_attempts = 0
end

-- Check if feature is enabled
function FeaturesClass:enabled(featureName)
    return self.features[featureName] or false
end

-- Load features from API
function FeaturesClass:load(resetAttempts)
    if resetAttempts then
        self.load_attempts = 0
    end
    
    self.load_attempts = self.load_attempts + 1
    
    if self.load_attempts >= 3 then
        Logger:log("Failed to load features from ^3https://api.reaperac.com", "error")
        return
    end
    
    local response = HTTP:await("https://api.reaperac.com/api/v1/features/api/v1/features")
    
    if response.status ~= 200 then
        Logger:log("Failed to load features from ^3https://api.reaperac.com/api/v1/features^7, retrying in 5 seconds.", "warn")
        Wait(5000)
        return self:load()
    end
    
    local features = json_decode(response.body)
    if not features then
        Logger:log("Failed to decode response from ^3https://api.reaperac.com/api/v1/features^7, retrying in 5 seconds.", "warn")
        Wait(5000)
        return self:load()
    end
    
    self.features = features
end

-- Create Features instance
Features = FeaturesClass.new()

-- Export functions
exports("IsFeatureEnabled", function(featureName)
    return Features:enabled(featureName)
end)

exports("LoadFeatures", function(resetAttempts)
    return Features:load(resetAttempts)
end)

exports("GetFeatures", function()
    return Features.features
end)