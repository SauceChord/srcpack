local LuaScanner = require "LuaScanner"
local T = require "LuaToken"

-- Helper variables. All tests use these pretty much
-- It's not "clean" but it's still "clean enough"
local Scanner = nil
local TokenIndex = nil

---Scans all tokens with a LuaScanner
---Intended by be used with expects_output function
---@param sourcecode string Lua source code to be scanned (lexically analyzed)
local function scans_sourcecode(sourcecode)
    Scanner = LuaScanner.new(sourcecode)
    Scanner:scanTokens()
    TokenIndex = 1
end

---Asserts token output of last scanned source code
---@param expectedType string Use LuaToken.lua predefined strings, like LuaToken.Terminator for example
---@param expectedLexeme string|nil The expected source code lexeme (bit of text that matches the type)
---@param expectedLiteral any The expected literal value of Numbers or Strings
---@param expectedLine integer? The expected line this token should appear on
local function expects_output(expectedType, expectedLexeme, expectedLiteral, expectedLine)
    assert.is_true(TokenIndex <= #Scanner.tokens,
        string.format("Too few tokens produced for expected output at index %d", TokenIndex))
    local token = Scanner.tokens[TokenIndex]
    assert.are_same(expectedType, token.type, string.format("Scanner.tokens[%d].type", TokenIndex))
    assert.are_same(expectedLexeme, token.lexeme, string.format("Scanner.tokens[%d].lexeme", TokenIndex))
    assert.are_same(expectedLiteral, token.literal, string.format("Scanner.tokens[%d].literal", TokenIndex))
    if expectedLine then
        assert.are_same(expectedLine, token.line, string.format("Scanner.tokens[%d].line", TokenIndex))
    end
    TokenIndex = TokenIndex + 1
end

---Utility for loading source code to tests
---@param filename string
---@return string text
local function read_all_text(filename)
    local f = assert(io.open(filename, "r"))
    local content = f:read("*all")
    f:close()
    return content
end

describe("tokenize RangeIterator.lua", function()
    it("produces tokens from source code sample", function()
        -- Read source code and pass it to LuaScanner
        local sourcecode = read_all_text("test_samples/RangeIterator.lua")
        scans_sourcecode(sourcecode)
        -- Line 1
        expects_output(T.Local, "local", nil, 1)
        expects_output(T.Function, "function", nil, 1)
        expects_output(T.Identifier, "range", nil, 1)
        expects_output(T.OpenBracket, "(", nil, 1)
        expects_output(T.Identifier, "from", nil, 1)
        expects_output(T.Comma, ",", nil, 1)
        expects_output(T.Identifier, "to", nil, 1)
        expects_output(T.Comma, ",", nil, 1)
        expects_output(T.Identifier, "step", nil, 1)
        expects_output(T.CloseBracket, ")", nil, 1)
        -- Line 2
        expects_output(T.Identifier, "step", nil, 2)
        expects_output(T.Assign, "=", nil, 2)
        expects_output(T.Identifier, "step", nil, 2)
        expects_output(T.Or, "or", nil, 2)
        expects_output(T.Number, "1", 1, 2)
        -- Line 3
        expects_output(T.Return, "return", nil, 3)
        expects_output(T.Function, "function", nil, 3)
        expects_output(T.OpenBracket, "(", nil, 3)
        expects_output(T.Identifier, "_", nil, 3)
        expects_output(T.Comma, ",", nil, 3)
        expects_output(T.Identifier, "lastvalue", nil, 3)
        expects_output(T.CloseBracket, ")", nil, 3)
        -- Line 4
        expects_output(T.Local, "local", nil, 4)
        expects_output(T.Identifier, "nextvalue", nil, 4)
        expects_output(T.Assign, "=", nil, 4)
        expects_output(T.Identifier, "lastvalue", nil, 4)
        expects_output(T.Plus, "+", nil, 4)
        expects_output(T.Identifier, "step", nil, 4)
        -- Line 5
        expects_output(T.If, "if", nil, 5)
        expects_output(T.Identifier, "step", nil, 5)
        expects_output(T.GreaterThan, ">", nil, 5)
        expects_output(T.Number, "0", 0, 5)
        expects_output(T.And, "and", nil, 5)
        expects_output(T.Identifier, "nextvalue", nil, 5)
        expects_output(T.LessThanOrEquals, "<=", nil, 5)
        expects_output(T.Identifier, "to", nil, 5)
        expects_output(T.Or, "or", nil, 5)
        expects_output(T.Identifier, "step", nil, 5)
        expects_output(T.LessThan, "<", nil, 5)
        expects_output(T.Number, "0", 0, 5)
        expects_output(T.And, "and", nil, 5)
        expects_output(T.Identifier, "nextvalue", nil, 5)
        expects_output(T.GreaterThanOrEquals, ">=", nil, 5)
        expects_output(T.Identifier, "to", nil, 5)
        expects_output(T.Or, "or", nil, 5)
        expects_output(T.Identifier, "step", nil, 5)
        expects_output(T.Equals, "==", nil, 5)
        expects_output(T.Number, "0", 0, 5)
        expects_output(T.Then, "then", nil, 5)
        -- Line 6
        expects_output(T.Return, "return", nil, 6)
        expects_output(T.Identifier, "nextvalue", nil, 6)
        -- Line 7
        expects_output(T.End, "end", nil, 7)
        -- Line 8
        expects_output(T.End, "end", nil, 8)
        expects_output(T.Comma, ",", nil, 8)
        expects_output(T.Nil, "nil", nil, 8)
        expects_output(T.Comma, ",", nil, 8)
        expects_output(T.Identifier, "from", nil, 8)
        expects_output(T.Minus, "-", nil, 8)
        expects_output(T.Identifier, "step", nil, 8)
        -- Line 9
        expects_output(T.End, "end", nil, 9)
        -- Line 10 (blank)
        -- Line 11
        expects_output(T.Local, "local", nil, 11)
        expects_output(T.Function, "function", nil, 11)
        expects_output(T.Identifier, "f", nil, 11)
        expects_output(T.OpenBracket, "(", nil, 11)
        expects_output(T.CloseBracket, ")", nil, 11)
        expects_output(T.Return, "return", nil, 11)
        expects_output(T.Number, "10", 10, 11)
        expects_output(T.Comma, ",", nil, 11)
        expects_output(T.Number, "0", 0, 11)
        expects_output(T.Comma, ",", nil, 11)
        expects_output(T.Minus, "-", nil, 11)
        expects_output(T.Number, "1", 1, 11)
        expects_output(T.End, "end", nil, 11)
        -- Line 12 (blank)
        -- Line 13
        expects_output(T.For, "for", nil, 13)
        expects_output(T.Identifier, "i", nil, 13)
        expects_output(T.In, "in", nil, 13)
        expects_output(T.Identifier, "range", nil, 13)
        expects_output(T.OpenBracket, "(", nil, 13)
        expects_output(T.Identifier, "f", nil, 13)
        expects_output(T.OpenBracket, "(", nil, 13)
        expects_output(T.CloseBracket, ")", nil, 13)
        expects_output(T.CloseBracket, ")", nil, 13)
        expects_output(T.Do, "do", nil, 13)
        -- Line 14
        expects_output(T.Identifier, "print", nil, 14)
        expects_output(T.OpenBracket, "(", nil, 14)
        expects_output(T.Identifier, "i", nil, 14)
        expects_output(T.CloseBracket, ")", nil, 14)
        -- Line 15
        expects_output(T.End, "end", nil, 15)
        expects_output(T.EndOfStream, nil, nil, 15)
    end)
end)
