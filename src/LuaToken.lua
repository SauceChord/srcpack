---@class LuaToken
---@field type string
---@field lexeme string
---@field literal any
---@field line integer
local LuaToken = {
    -- These fields exist for easier reactoring.
    -- Comments
    Comment = "Comment",                         -- --
    MultilineComment = "MultilineComment",       -- --[[]]
    -- General
    Terminator = "Terminator",                   -- ;
    OpenScope = "OpenScope",                     -- {
    CloseScope = "CloseScope",                   -- }
    Label = "Label",                             -- ::
    Concat = "Concat",                           -- ..
    VarArgs = "VarArgs",                         -- ...
    Assign = "Assign",                           -- =
    -- Types
    Number = "Number",                           -- 14, 0x3, 3.26e-4, 0x2p+2
    String = "String",                           -- "", '', [[]]
    --- Grouping
    OpenBracket = "OpenBracket",                 -- (
    CloseBracket = "CloseBracket",               -- )
    Comma = "Comma",                             -- ,
    -- Indexing
    OpenIndex = "OpenIndex",                     -- [
    CloseIndex = "CloseIndex",                   -- ]
    FieldSelector = "FieldSelector",             -- .
    MethodCall = "MethodCall",                   -- :
    -- Binary
    BinaryNot = "BinaryNot",                     -- ~
    BinaryAnd = "BinaryAnd",                     -- &
    BinaryOr = "BinaryOr",                       -- |
    BinaryShl = "BinaryShl",                     -- <<
    BinaryShr = "BinaryShr",                     -- >>
    -- Math
    Minus = "Minus",                             -- -
    Plus = "Plus",                               -- +
    Multiply = "Multiply",                       -- *
    Divide = "Divide",                           -- /
    DivideFloor = "DivideFloor",                 -- //
    Modulus = "Modulus",                         -- %
    Exponent = "Exponent",                       -- ^
    -- Logic
    Equals = "Equals",                           -- ==
    NotEquals = "NotEquals",                     -- ~=
    LessThan = "LessThan",                       -- <
    LessThanOrEquals = "LessThanOrEquals",       -- <=
    GreaterThan = "GreaterThan",                 -- >
    GreaterThanOrEquals = "GreaterThanOrEquals", -- >=
    -- Misc
    Error = "Error",                             -- Anything uncovered
    EndOfStream = "EndOfStream",                 -- Last Token
}

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
