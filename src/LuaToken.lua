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
    Identifier = "Identifier",                   -- Users identifier, like "i" or "doSomething" (variable and function names etc)
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
    -- 22 Keywords
    Keywords = nil,                              -- Assigned below
    And = "And",                                 -- and
    Break = "Break",                             -- break
    Do = "Do",                                   -- do
    Else = "Else",                               -- else
    ElseIf = "ElseIf",                           -- elseif
    End = "End",                                 -- end
    False = "False",                             -- false
    For = "For",                                 -- for
    Function = "Function",                       -- function
    Goto = "Goto",                               -- goto
    If = "If",                                   -- if
    In = "In",                                   -- in
    Local = "Local",                             -- local
    Nil = "Nil",                                 -- nil
    Not = "Not",                                 -- not
    Or = "Or",                                   -- or
    Repeat = "Repeat",                           -- repeat
    Return = "Return",                           -- return
    Then = "Then",                               -- then
    True = "True",                               -- true
    Until = "Until",                             -- until
    While = "While",                             -- while
    -- Misc
    Error = "Error",                             -- Anything uncovered
    EndOfStream = "EndOfStream",                 -- Last Token
}

LuaToken.Keywords = {
    ["and"] = "And",
    ["break"] = "Break",
    ["do"] = "Do",
    ["else"] = "Else",
    ["elseif"] = "ElseIf",
    ["end"] = "End",
    ["false"] = "False",
    ["for"] = "For",
    ["function"] = "Function",
    ["goto"] = "Goto",
    ["if"] = "If",
    ["in"] = "In",
    ["local"] = "Local",
    ["nil"] = "Nil",
    ["not"] = "Not",
    ["or"] = "Or",
    ["repeat"] = "Repeat",
    ["return"] = "Return",
    ["then"] = "Then",
    ["true"] = "True",
    ["until"] = "Until",
    ["while"] = "While",
}

---@return string
function LuaToken:tostring()
    return string.format("%s %s %s %d", tostring(self.type), tostring(self.lexeme), tostring(self.literal), self.line)
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
