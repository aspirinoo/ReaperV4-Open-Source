-- Reaper AntiCheat - Client Entity System
-- Cleaned and deobfuscated version

local ClearAreaOfObjects = ClearAreaOfObjects
local RPC = RPC

-- Register cleanup event
RPC.onNet("entities:cleanup", function()
    ClearAreaOfObjects(0.0, 0.0, 0.0, 9999.0, 0)
end)