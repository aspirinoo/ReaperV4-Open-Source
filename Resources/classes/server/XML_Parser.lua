-- ReaperV4 Server XML_Parser Class
-- Clean and optimized version

local string_gsub = string.gsub
local string_find = string.find
local string_sub = string.sub
local string_format = string.format
local string_byte = string.byte
local string_char = string.char
local tonumber = tonumber
local table_insert = table.insert
local table_remove = table.remove
local type = type

-- XML Parser class
local XmlParser = {}

-- Convert string to XML string
function XmlParser.ToXmlString(str)
    str = string_gsub(str, "&", "&amp;")
    str = string_gsub(str, "<", "&lt;")
    str = string_gsub(str, ">", "&gt;")
    str = string_gsub(str, "\"", "&quot;")
    str = string_gsub(str, "([^%w%&%;%p%\t% ])", function(char)
        return string_format("&#x%X;", string_byte(char))
    end)
    return str
end

-- Convert XML string to string
function XmlParser.FromXmlString(str)
    str = string_gsub(str, "&#x([%x]+);", function(hex)
        return string_char(tonumber(hex, 16))
    end)
    str = string_gsub(str, "&#([0-9]+);", function(dec)
        return string_char(tonumber(dec, 10))
    end)
    str = string_gsub(str, "&quot;", "\"")
    str = string_gsub(str, "&apos;", "'")
    str = string_gsub(str, "&gt;", ">")
    str = string_gsub(str, "&lt;", "<")
    str = string_gsub(str, "&amp;", "&")
    return str
end

-- Parse XML arguments
function XmlParser.ParseArgs(parser, node, args)
    string_gsub(args, "(%w+)=([\"'])(.-)%2", function(name, quote, value)
        node:addProperty(name, parser:FromXmlString(value))
    end)
end

-- Parse XML text
function XmlParser.ParseXmlText(parser, xmlText)
    local stack = {}
    local root = newNode()
    table_insert(stack, root)
    
    local pos = 1
    local startPos = 1
    
    while true do
        local start, endPos, close, tagName, args, selfClose = string_find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", pos)
        if not start then
            break
        end
        
        local text = string_sub(xmlText, startPos, start - 1)
        if not string_find(text, "^%s*$") then
            local currentValue = root:value() or ""
            text = parser:FromXmlString(text)
            currentValue = currentValue .. text
            stack[#stack]:setValue(currentValue)
        end
        
        if selfClose == "/" then
            local child = newNode(tagName)
            parser:ParseArgs(child, args)
            root:addChild(child)
        elseif close == "" then
            local child = newNode(tagName)
            parser:ParseArgs(child, args)
            table_insert(stack, child)
            root = child
        else
            local child = table_remove(stack)
            if #stack < 1 then
                error("XmlParser: nothing to close with " .. tagName)
            end
            if child:name() ~= tagName then
                error("XmlParser: trying to close " .. child:name() .. " with " .. tagName)
            end
            stack[#stack]:addChild(child)
            root = stack[#stack]
        end
        
        pos = endPos + 1
        startPos = endPos + 1
    end
    
    local remainingText = string_sub(xmlText, pos)
    if #stack > 1 then
        error("XmlParser: unclosed " .. stack[#stack]:name())
    end
    
    return root
end

-- Create new parser
function newParser()
    return XmlParser
end

-- Create new node
function newNode(name)
    local node = {}
    node.___value = nil
    node.___name = name
    node.___children = {}
    node.___props = {}
    
    function node:value()
        return self.___value
    end
    
    function node:setValue(value)
        self.___value = value
    end
    
    function node:name()
        return self.___name
    end
    
    function node:setName(name)
        self.___name = name
    end
    
    function node:children()
        return self.___children
    end
    
    function node:numChildren()
        return #self.___children
    end
    
    function node:addChild(child)
        if self[child:name()] then
            if type(self[child:name()].name) == "function" then
                local children = {}
                table_insert(children, self[child:name()])
                self[child:name()] = children
            end
            table_insert(self[child:name()], child)
        else
            self[child:name()] = child
        end
        table_insert(self.___children, child)
    end
    
    function node:properties()
        return self.___props
    end
    
    function node:numProperties()
        return #self.___props
    end
    
    function node:addProperty(name, value)
        local propName = "@" .. name
        if self[propName] then
            if type(self[propName]) == "string" then
                local values = {}
                table_insert(values, self[propName])
                self[propName] = values
            end
            table_insert(self[propName], value)
        else
            self[propName] = value
        end
        table_insert(self.___props, {
            name = name,
            value = self[name]
        })
    end
    
    return node
end

-- Export functions
exports("NewParser", function()
    return newParser()
end)

exports("NewNode", function(name)
    return newNode(name)
end)

exports("ParseXmlText", function(parser, xmlText)
    return parser:ParseXmlText(xmlText)
end)

exports("ToXmlString", function(str)
    return XmlParser.ToXmlString(str)
end)

exports("FromXmlString", function(str)
    return XmlParser.FromXmlString(str)
end)