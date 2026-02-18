-- ReaperV4 Server Command Class
-- Clean and optimized version

local Logger = Logger
local class = class
local RegisterCommand = RegisterCommand
local type = type
local tostring = tostring
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_copy = table.copy
local json_encode = json.encode
local json_decode = json.decode

-- Command class definition
local CommandClass = class("Command")

-- Constructor
function CommandClass:constructor()
    self.commands = {}
    self.aliases = {}
    self.permissions = {}
    self.help = {}
    self.usage = {}
    self.examples = {}
end

-- Register command
function CommandClass:register(name, callback, permission, help, usage, example)
    if type(name) ~= "string" then
        error("Command name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Command callback must be a function", 2)
    end
    
    self.commands[name] = callback
    self.permissions[name] = permission
    self.help[name] = help or "No help available"
    self.usage[name] = usage or "No usage information"
    self.examples[name] = example or "No examples available"
end

-- Register command alias
function CommandClass:registerAlias(alias, command)
    if type(alias) ~= "string" then
        error("Alias must be a string", 2)
    end
    
    if type(command) ~= "string" then
        error("Command must be a string", 2)
    end
    
    if not self.commands[command] then
        error(string_format("Command '%s' not found", command), 2)
    end
    
    self.aliases[alias] = command
end

-- Execute command
function CommandClass:execute(source, name, args)
    if type(name) ~= "string" then
        error("Command name must be a string", 2)
    end
    
    -- Check for alias
    if self.aliases[name] then
        name = self.aliases[name]
    end
    
    -- Check if command exists
    if not self.commands[name] then
        Logger.log(Logger, string_format("^3%s^7 is not a valid command. For a list of commands do 'reaper help'", name), "error")
        return false
    end
    
    -- Check permissions
    if self.permissions[name] then
        if not self:hasPermission(source, self.permissions[name]) then
            Logger.log(Logger, string_format("^1You don't have permission to use command '%s'", name), "error")
            return false
        end
    end
    
    -- Execute command
    local success, result = pcall(self.commands[name], source, args)
    
    if not success then
        Logger.log(Logger, string_format("^1Error executing command '%s': %s", name, result), "error")
        return false
    end
    
    return true
end

-- Check permission
function CommandClass:hasPermission(source, permission)
    if type(permission) ~= "string" then
        return true
    end
    
    -- Check if source is console
    if source == 0 then
        return true
    end
    
    -- Check if player has permission
    local player = Player(source)
    if player then
        return player:hasPermission(permission)
    end
    
    return false
end

-- Get command help
function CommandClass:getHelp(name)
    if type(name) ~= "string" then
        return nil
    end
    
    return self.help[name]
end

-- Get command usage
function CommandClass:getUsage(name)
    if type(name) ~= "string" then
        return nil
    end
    
    return self.usage[name]
end

-- Get command example
function CommandClass:getExample(name)
    if type(name) ~= "string" then
        return nil
    end
    
    return self.examples[name]
end

-- Get all commands
function CommandClass:getCommands()
    return table_copy(self.commands)
end

-- Get command aliases
function CommandClass:getAliases()
    return table_copy(self.aliases)
end

-- Remove command
function CommandClass:remove(name)
    if type(name) ~= "string" then
        error("Command name must be a string", 2)
    end
    
    self.commands[name] = nil
    self.permissions[name] = nil
    self.help[name] = nil
    self.usage[name] = nil
    self.examples[name] = nil
    
    -- Remove aliases
    for alias, command in pairs(self.aliases) do
        if command == name then
            self.aliases[alias] = nil
        end
    end
end

-- Get command list
function CommandClass:getCommandList()
    local commands = {}
    
    for name, _ in pairs(self.commands) do
        table_insert(commands, {
            name = name,
            help = self.help[name],
            usage = self.usage[name],
            example = self.examples[name],
            permission = self.permissions[name]
        })
    end
    
    return commands
end

-- Get command list as JSON
function CommandClass:getCommandListAsJSON()
    return json_encode(self:getCommandList())
end

-- Create command instance
Command = CommandClass.new()

-- Register main reaper command
RegisterCommand("reaper", function(source, args, rawCommand)
    if #args == 0 then
        Logger.log(Logger, "^3Usage: reaper <command> [args]", "info")
        return
    end
    
    local command = args[1]
    table_remove(args, 1)
    
    Command:execute(source, command, args)
end, false)

-- Register help command
Command:register("help", function(source, args)
    local commands = Command:getCommandList()
    
    Logger.log(Logger, "^2Available commands:", "info")
    for _, cmd in pairs(commands) do
        Logger.log(Logger, string_format("^3%s^7 - %s", cmd.name, cmd.help), "info")
        if cmd.usage then
            Logger.log(Logger, string_format("^6Usage:^7 %s", cmd.usage), "info")
        end
        if cmd.example then
            Logger.log(Logger, string_format("^6Example:^7 %s", cmd.example), "info")
        end
    end
end, nil, "Show available commands", "reaper help", "reaper help")

-- Register list command
Command:register("list", function(source, args)
    local commands = Command:getCommandList()
    
    Logger.log(Logger, string_format("^2Found %d commands:", #commands), "info")
    for _, cmd in pairs(commands) do
        Logger.log(Logger, string_format("^3%s^7 - %s", cmd.name, cmd.help), "info")
    end
end, nil, "List all commands", "reaper list", "reaper list")

-- Register info command
Command:register("info", function(source, args)
    if #args == 0 then
        Logger.log(Logger, "^1Usage: reaper info <command>", "error")
        return
    end
    
    local command = args[1]
    local help = Command:getHelp(command)
    local usage = Command:getUsage(command)
    local example = Command:getExample(command)
    
    if help then
        Logger.log(Logger, string_format("^2Command:^7 %s", command), "info")
        Logger.log(Logger, string_format("^6Help:^7 %s", help), "info")
        if usage then
            Logger.log(Logger, string_format("^6Usage:^7 %s", usage), "info")
        end
        if example then
            Logger.log(Logger, string_format("^6Example:^7 %s", example), "info")
        end
    else
        Logger.log(Logger, string_format("^1Command '%s' not found", command), "error")
    end
end, nil, "Get information about a command", "reaper info <command>", "reaper info help")

-- Export functions
exports("RegisterCommand", function(name, callback, permission, help, usage, example)
    return Command:register(name, callback, permission, help, usage, example)
end)

exports("RegisterCommandAlias", function(alias, command)
    return Command:registerAlias(alias, command)
end)

exports("ExecuteCommand", function(source, name, args)
    return Command:execute(source, name, args)
end)

exports("GetCommandHelp", function(name)
    return Command:getHelp(name)
end)

exports("GetCommandUsage", function(name)
    return Command:getUsage(name)
end)

exports("GetCommandExample", function(name)
    return Command:getExample(name)
end)

exports("GetCommands", function()
    return Command:getCommands()
end)

exports("GetCommandList", function()
    return Command:getCommandList()
end)

exports("GetCommandListAsJSON", function()
    return Command:getCommandListAsJSON()
end)

exports("RemoveCommand", function(name)
    return Command:remove(name)
end)
