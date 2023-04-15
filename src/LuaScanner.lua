---@class LuaScanner
---@field source string
---@field tokens integer[]
---@field start integer
---@field current integer
---@field line integer
local LuaScanner = { }

local LuaToken = require "LuaToken"

---@return string
function LuaScanner:tostring()
    return string.format("LuaScanner")
end

---@return integer[]
function LuaScanner:scanTokens()
    table.insert(self.tokens, LuaToken.new("<eof>", nil, nil, 1))
    return self.tokens
end

function LuaScanner:scanToken()
    local c = self:advance()
    local switch = {
        ['('] = function() return LuaToken.new("LEFT_PAREN", c, nil, self.line) end,
        [')'] = function() return LuaToken.new("RIGHT_PAREN", c, nil, self.line) end,
        ['{'] = function() return LuaToken.new("LEFT_BRACE", c, nil, self.line) end,
    }
    return (switch[c] or error(string.format("unhandled character %s in token stream at line %d", c, self.line)))()
end

---@return string char   
function LuaScanner:advance()
    self.current = self.current + 1
    return self.source:sub(self.current - 1, self.current - 1)
end

---@return boolean
function LuaScanner:isAtEnd()
    return self.current > #self.source
end

local mt = { __index = LuaScanner, __tostring = LuaScanner.tostring }

---@param source string
---@return LuaScanner
function LuaScanner.new(source)
    local o = {
        source = source,
        tokens = {},
        start = 1,
        current = 1,
        line = 1,
    }
    setmetatable(o, mt)
    return o
end

return LuaScanner
