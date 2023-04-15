---@class LuaToken
---@field type string
---@field lexeme string
---@field literal any
---@field line integer
local LuaToken = { }

---@return string
function LuaToken:tostring()
    return string.format("%s %s %s %d", tostring(self.type), tostring(self.lexeme), tostring(self.literal), self.line)
end

function LuaToken:trimCommentEndline()
    if self.lexeme:sub(-1) == '\r' or self.lexeme:sub(-1) == '\n' then
        self.lexeme = self.lexeme:sub(1, -2)
    end
end

local mt = { __index = LuaToken, __tostring = LuaToken.tostring }

---@param type string
---@param lexeme string|nil
---@param literal any
---@param line integer
---@return LuaToken
function LuaToken.new(type, lexeme, literal, line)
    local o = {
        type = type,
        lexeme = lexeme,
        literal = literal,
        line = line,
    }
    setmetatable(o, mt)
    return o
end

return LuaToken
