-- Reaper AntiCheat - Server JavaScript Support System
-- Cleaned and deobfuscated version

local TriggerClientEvent = TriggerClientEvent
local exports = exports

-- TriggerClientEvent export for JavaScript support
exports("TriggerClientEvent", function(eventName, targetPlayer, ...)
    TriggerClientEvent(eventName, targetPlayer, ...)
end)