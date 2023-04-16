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
---@param expectedLine integer The expected line this token should appear on
local function expects_output(expectedType, expectedLexeme, expectedLiteral, expectedLine)
    assert.is_true(TokenIndex <= #Scanner.tokens,
        string.format("Too few tokens produced for expected output at index %d", TokenIndex))
    local token = Scanner.tokens[TokenIndex]
    assert.are_same(expectedType, token.type, string.format("Scanner.tokens[%d].type", TokenIndex))
    assert.are_same(expectedLexeme, token.lexeme, string.format("Scanner.tokens[%d].lexeme", TokenIndex))
    assert.are_same(expectedLiteral, token.literal, string.format("Scanner.tokens[%d].literal", TokenIndex))
    assert.are_same(expectedLine, token.line, string.format("Scanner.tokens[%d].line", TokenIndex))
    TokenIndex = TokenIndex + 1
end

-- Note that many of the tests doesn't use valid Lua source code
-- It is the parsers job to deal with syntax checking, not the scanners
-- So reader be warned for some confusing source tokenizing
describe("LuaScanner", function()
    describe("new(source)", function()
        it("sets fields", function()
            local scanner = LuaScanner.new("--")
            assert.are_same("--", scanner.source, "source")
            assert.are_same(0, #scanner.tokens, "tokens")
            assert.are_same(1, scanner.start, "start")
            assert.are_same(1, scanner.current, "current")
            assert.are_same(1, scanner.line, "line")
        end)
    end)
    describe("tostring(scanner)", function()
        it("return a literal string", function()
            local scanner = LuaScanner.new("")
            assert.are_same("LuaScanner", tostring(scanner))
        end)
    end)
    describe("scanTokens()", function()
        describe("with valid inputs", function()
            it("produces end of stream token", function()
                scans_sourcecode("")
                expects_output(T.EndOfStream, nil, nil, 1)
            end)
            it("produces 10 tokens from this source", function()
                scans_sourcecode("<><<<\n * \t--Lorem *\n 'ipsum' [[dolor\nsit]];")
                expects_output(T.LessThan, "<", nil, 1)
                expects_output(T.GreaterThan, ">", nil, 1)
                expects_output(T.BinaryShl, "<<", nil, 1)
                expects_output(T.LessThan, "<", nil, 1)
                expects_output(T.Multiply, "*", nil, 2)
                expects_output(T.Comment, "--Lorem *", nil, 2)
                expects_output(T.String, "'ipsum'", "ipsum", 3)
                expects_output(T.String, "[[dolor\nsit]]", "dolor\nsit", 3)
                expects_output(T.Terminator, ";", nil, 4)
                expects_output(T.EndOfStream, nil, nil, 4)
            end)
            it("generates error tokens when it doesn't know what to do", function()
                scans_sourcecode("@@")
                expects_output(T.Error, "@", nil, 1)
                expects_output(T.Error, "@", nil, 1)
                expects_output(T.EndOfStream, nil, nil, 1)
            end)
            describe("comments", function()
                it("handles -- comments", function()
                    scans_sourcecode("--Lorem\n--ipsum")
                    expects_output(T.Comment, "--Lorem", nil, 1)
                    expects_output(T.Comment, "--ipsum", nil, 2)
                    expects_output(T.EndOfStream, nil, nil, 2)
                end)
                it("handles --[[]] comments", function()
                    scans_sourcecode("--[[Lorem\nipsum]]")
                    expects_output(T.MultilineComment, "--[[Lorem\nipsum]]", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 2)
                end)
            end)
            describe("general tokens", function()
                it("handles ; terminators", function()
                    scans_sourcecode(";;")
                    expects_output(T.Terminator, ";", nil, 1)
                    expects_output(T.Terminator, ";", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles { open scopes", function()
                    scans_sourcecode("{{")
                    expects_output(T.OpenScope, "{", nil, 1)
                    expects_output(T.OpenScope, "{", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles } close scopes", function()
                    scans_sourcecode("}}")
                    expects_output(T.CloseScope, "}", nil, 1)
                    expects_output(T.CloseScope, "}", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles :: label prefix/postfixes", function()
                    scans_sourcecode("::::")
                    expects_output(T.Label, "::", nil, 1)
                    expects_output(T.Label, "::", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles .. concatenation", function()
                    scans_sourcecode(".. ..")
                    expects_output(T.Concat, "..", nil, 1)
                    expects_output(T.Concat, "..", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles ... variable arguments", function()
                    scans_sourcecode("......")
                    expects_output(T.VarArgs, "...", nil, 1)
                    expects_output(T.VarArgs, "...", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles assigns", function()
                    scans_sourcecode("= =")
                    expects_output(T.Assign, "=", nil, 1)
                    expects_output(T.Assign, "=", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
            describe("types", function()
                it("handles integer numbers", function()
                    scans_sourcecode("0 1 2 3 4 5 6 7 8 9 01234567890")
                    expects_output(T.Number, "0", 0, 1)
                    expects_output(T.Number, "1", 1, 1)
                    expects_output(T.Number, "2", 2, 1)
                    expects_output(T.Number, "3", 3, 1)
                    expects_output(T.Number, "4", 4, 1)
                    expects_output(T.Number, "5", 5, 1)
                    expects_output(T.Number, "6", 6, 1)
                    expects_output(T.Number, "7", 7, 1)
                    expects_output(T.Number, "8", 8, 1)
                    expects_output(T.Number, "9", 9, 1)
                    expects_output(T.Number, "01234567890", 1234567890, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles decimal numbers", function()
                    scans_sourcecode("0.0 1.3 .5")
                    expects_output(T.Number, "0.0", 0, 1)
                    expects_output(T.Number, "1.3", 1.3, 1)
                    expects_output(T.Number, ".5", .5, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles hexadecimal numbers", function()
                    scans_sourcecode("0x0 0x12345678 0xabcdef00")
                    expects_output(T.Number, "0x0", 0, 1)
                    expects_output(T.Number, "0x12345678", 305419896, 1)
                    expects_output(T.Number, "0xabcdef00", 2882400000, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles exponentiated numbers", function()
                    scans_sourcecode("1E2 1e+2 1e-2 0x1P8 0x1p+8 0x1p-1")
                    -- Usual exponent is e or E
                    expects_output(T.Number, "1E2", 100, 1)
                    expects_output(T.Number, "1e+2", 100, 1)
                    expects_output(T.Number, "1e-2", .01, 1)
                    -- Hexadecimal exponent is p or P
                    expects_output(T.Number, "0x1P8", 256, 1)
                    expects_output(T.Number, "0x1p+8", 256, 1)
                    expects_output(T.Number, "0x1p-1", .5, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles '' strings", function()
                    scans_sourcecode("'Lorem'")
                    expects_output(T.String, "'Lorem'", "Lorem", 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it('handles "" strings', function()
                    scans_sourcecode('"Lorem"')
                    expects_output(T.String, '"Lorem"', "Lorem", 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles [[]] strings", function()
                    scans_sourcecode("[[Lorem\nipsum]]")
                    expects_output(T.String, "[[Lorem\nipsum]]", "Lorem\nipsum", 1)
                    expects_output(T.EndOfStream, nil, nil, 2)
                end)
                it("handles strings with escape characters", function()
                    scans_sourcecode("'Lorem\\'ipsum' 'dolor' [[sit\\]]]")
                    expects_output(T.String, "'Lorem\\'ipsum'", "Lorem\\'ipsum", 1)
                    expects_output(T.String, "'dolor'", "dolor", 1)
                    expects_output(T.String, "[[sit\\]]]", "sit\\]", 1) -- odd case?
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
            describe("grouping", function()
                it("handles open brackets", function()
                    scans_sourcecode("((")
                    expects_output(T.OpenBracket, "(", nil, 1)
                    expects_output(T.OpenBracket, "(", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles close brackets", function()
                    scans_sourcecode("))")
                    expects_output(T.CloseBracket, ")", nil, 1)
                    expects_output(T.CloseBracket, ")", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles commas", function()
                    scans_sourcecode(",,")
                    expects_output(T.Comma, ",", nil, 1)
                    expects_output(T.Comma, ",", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
            describe("indexing", function()
                it("handles open indexes", function()
                    scans_sourcecode("[ [")
                    expects_output(T.OpenIndex, "[", nil, 1)
                    expects_output(T.OpenIndex, "[", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles close indexs", function()
                    scans_sourcecode("]]")
                    expects_output(T.CloseIndex, "]", nil, 1)
                    expects_output(T.CloseIndex, "]", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles field selectors", function()
                    scans_sourcecode(". .")
                    expects_output(T.FieldSelector, ".", nil, 1)
                    expects_output(T.FieldSelector, ".", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles method call selectors", function()
                    scans_sourcecode(":")
                    expects_output(T.MethodCall, ":", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
            describe("binary", function()
                it("handles not operators", function()
                    scans_sourcecode("~~")
                    expects_output(T.BinaryNot, "~", nil, 1)
                    expects_output(T.BinaryNot, "~", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles and operators", function()
                    scans_sourcecode("&&")
                    expects_output(T.BinaryAnd, "&", nil, 1)
                    expects_output(T.BinaryAnd, "&", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles or operators", function()
                    scans_sourcecode("||")
                    expects_output(T.BinaryOr, "|", nil, 1)
                    expects_output(T.BinaryOr, "|", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles left bit shifts", function()
                    scans_sourcecode("<<<<")
                    expects_output(T.BinaryShl, "<<", nil, 1)
                    expects_output(T.BinaryShl, "<<", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles right bit shifts", function()
                    scans_sourcecode(">>")
                    expects_output(T.BinaryShr, ">>", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
            describe("math", function()
                it("handles minuses", function()
                    scans_sourcecode("- -")
                    expects_output(T.Minus, "-", nil, 1)
                    expects_output(T.Minus, "-", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("returns pluses", function()
                    scans_sourcecode("++")
                    expects_output(T.Plus, "+", nil, 1)
                    expects_output(T.Plus, "+", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles multipys", function()
                    scans_sourcecode("**")
                    expects_output(T.Multiply, "*", nil, 1)
                    expects_output(T.Multiply, "*", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles divides", function()
                    scans_sourcecode("/ /")
                    expects_output(T.Divide, "/", nil, 1)
                    expects_output(T.Divide, "/", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles floor divisions", function()
                    scans_sourcecode("////")
                    expects_output(T.DivideFloor, "//", nil, 1)
                    expects_output(T.DivideFloor, "//", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles moduluses", function()
                    scans_sourcecode("%%")
                    expects_output(T.Modulus, "%", nil, 1)
                    expects_output(T.Modulus, "%", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles exponents", function()
                    scans_sourcecode("^^")
                    expects_output(T.Exponent, "^", nil, 1)
                    expects_output(T.Exponent, "^", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
            describe("logic", function()
                it("handles equals", function()
                    scans_sourcecode("====")
                    expects_output(T.Equals, "==", nil, 1)
                    expects_output(T.Equals, "==", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles not equals", function()
                    scans_sourcecode("~=~=")
                    expects_output(T.NotEquals, "~=", nil, 1)
                    expects_output(T.NotEquals, "~=", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles less thans", function()
                    scans_sourcecode("< <")
                    expects_output(T.LessThan, "<", nil, 1)
                    expects_output(T.LessThan, "<", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles less than or equals", function()
                    scans_sourcecode("<=<=")
                    expects_output(T.LessThanOrEquals, "<=", nil, 1)
                    expects_output(T.LessThanOrEquals, "<=", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles greater thans", function()
                    scans_sourcecode("> >")
                    expects_output(T.GreaterThan, ">", nil, 1)
                    expects_output(T.GreaterThan, ">", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
                it("handles greater than or equals", function()
                    scans_sourcecode(">=>=")
                    expects_output(T.GreaterThanOrEquals, ">=", nil, 1)
                    expects_output(T.GreaterThanOrEquals, ">=", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
            describe("miscellaneous details", function()
                it("increments line number on \\r or \\n", function()
                    -- This is what lua source llex.c does:
                    -- it increments line number for either \r or \n
                    scans_sourcecode("\r\n")
                    expects_output(T.EndOfStream, nil, nil, 3)
                end)
                it("ignores whitespace ' ', \\f, \\t and \\v", function()
                    scans_sourcecode(" \f\t\v-- But not in comments")
                    expects_output(T.Comment, "-- But not in comments", nil, 1)
                    expects_output(T.EndOfStream, nil, nil, 1)
                end)
            end)
        end)
    end)
    describe("scanner:isAtEnd()", function()
        it("returns true on new('')", function()
            local scanner = LuaScanner.new("")
            assert.is_true(scanner:isAtEnd())
        end)
        it("returns false on new(' ')", function()
            local scanner = LuaScanner.new(" ")
            assert.is_false(scanner:isAtEnd())
        end)
    end)
    describe("scanner:matchAny(expected)", function()
        it("returns false when at end", function()
            local scanner = LuaScanner.new("")
            assert.is_false(scanner:matchAny('*'))
        end)
        it("returns false on no match", function()
            local scanner = LuaScanner.new("+")
            assert.is_false(scanner:matchAny('*'))
        end)
        it("returns true on match", function()
            local scanner = LuaScanner.new("*")
            assert.is_true(scanner:matchAny('*'))
        end)
    end)
    describe("scanner:matchMany(expected) #focus", function()
        it("returns false when at end", function()
            local scanner = LuaScanner.new("")
            assert.is_false(scanner:matchMany('--'))
            assert.are.same(1, scanner.current, "current")
        end)
        it("returns true on match", function()
            local scanner = LuaScanner.new("--")
            assert.is_true(scanner:matchMany('--'))
            assert.are.same(3, scanner.current, "current")
        end)
        it("returns true on several matches", function()
            local scanner = LuaScanner.new("--abb")
            assert.is_true(scanner:matchMany('--'))
            assert.are.same(3, scanner.current, "current")
            assert.is_true(scanner:matchMany('a'))
            assert.are.same(4, scanner.current, "current")
            assert.is_true(scanner:matchMany('bb'))
            assert.are.same(6, scanner.current, "current")
        end)
    end)
end)
