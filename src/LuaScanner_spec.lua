local LuaScanner = require "LuaScanner"

describe("LuaScanner", function()
    describe("new(source)", function()
        it("sets fields", function()
            local scanner = LuaScanner.new("--")
            assert.are.same("--", scanner.source, "source")
            assert.are.same(0, #scanner.tokens, "tokens")
            assert.are.same(1, scanner.start, "start")
            assert.are.same(1, scanner.current, "current")
            assert.are.same(1, scanner.line, "line")
        end)
    end)
    describe("tostring(scanner)", function()
        it("return a literal string", function()
            local scanner = LuaScanner.new("")
            assert.are.same("LuaScanner", tostring(scanner))
        end)
    end)
    describe("scanner:scanTokens()", function()
        describe("with valid inputs", function()
            it("produces an <eof> token", function()
                local scanner = LuaScanner.new("")
                local actualTokens = scanner:scanTokens()
                assert.are.same(1, #scanner.tokens, "#scanner.tokens")
                assert.are.same(1, #actualTokens, "#actualTokens")
                assert.are.same("<eof> nil nil 1", tostring(actualTokens[1]), "token")
            end)
            it("produces three tokens from source", function()
                local scanner = LuaScanner.new("   <   >   \n")
                scanner:scanTokens()
                assert.are.same(3, #scanner.tokens, "#scanner.tokens")
                assert.are.same("L < nil 1", tostring(scanner.tokens[1]), "tokens[1]")
                assert.are.same("G > nil 1", tostring(scanner.tokens[2]), "tokens[2]")
                assert.are.same("<eof> nil nil 2", tostring(scanner.tokens[3]), "tokens[3]")
            end)
            it("produces 10 tokens from source", function()
                local scanner = LuaScanner.new("<><<<\n * \t--comment*\n 'string' [[multi\nline]];")
                local i = 0
                local function tk() i = i + 1 return tostring(scanner.tokens[i]) end
                local function err() return string.format("tokens[%d]", i) end
                scanner:scanTokens()
                assert.are.same(10, #scanner.tokens, "#scanner.tokens")
                assert.are.same("L < nil 1", tk(), err())
                assert.are.same("G > nil 1", tk(), err())
                assert.are.same("SHL << nil 1", tk(), err())
                assert.are.same("L < nil 1", tk(), err())
                assert.are.same("MULT * nil 2", tk(), err())
                assert.are.same("COMMENT --comment* nil 2", tk(), err())
                assert.are.same("STRING 'string' string 3", tk(), err())
                assert.are.same("STRING [[multi\nline]] multi\nline 3", tk(), err())
                assert.are.same("SEMICOLON ; nil 4", tk(), err())
                assert.are.same("<eof> nil nil 4", tk(), err())
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
    describe("scanner:scanToken()", function()
        it("returns <eof>", function()
            local scanner = LuaScanner.new("")
            assert.are.same("<eof> nil nil 1", scanner:scanToken():tostring())
        end)
        it("returns UNKNOWN", function()
            local scanner = LuaScanner.new("@")
            assert.are.same('UNKNOWN @ nil 1', scanner:scanToken():tostring())
        end)
        it("returns LEFT_PAREN", function()
            local scanner = LuaScanner.new("(")
            assert.are.same("LEFT_PAREN ( nil 1", scanner:scanToken():tostring())
        end)
        it("returns RIGHT_PAREN", function()
            local scanner = LuaScanner.new(")")
            assert.are.same("RIGHT_PAREN ) nil 1", scanner:scanToken():tostring())
        end)
        it("returns LEFT_BRACE", function()
            local scanner = LuaScanner.new("{")
            assert.are.same("LEFT_BRACE { nil 1", scanner:scanToken():tostring())
        end)
        it("returns RIGHT_BRACE", function()
            local scanner = LuaScanner.new("}")
            assert.are.same("RIGHT_BRACE } nil 1", scanner:scanToken():tostring())
        end)
        it("returns RIGHT_BRACKET", function()
            local scanner = LuaScanner.new("]")
            assert.are.same("RIGHT_BRACKET ] nil 1", scanner:scanToken():tostring())
        end)
        it("returns LEFT_BRACKET", function()
            local scanner = LuaScanner.new("[")
            assert.are.same("LEFT_BRACKET [ nil 1", scanner:scanToken():tostring())
        end)
        it("returns COMMA", function()
            local scanner = LuaScanner.new(",")
            assert.are.same("COMMA , nil 1", scanner:scanToken():tostring())
        end)
        it("returns DOT", function()
            local scanner = LuaScanner.new(".")
            assert.are.same("DOT . nil 1", scanner:scanToken():tostring())
        end)
        it("returns MINUS", function()
            local scanner = LuaScanner.new("-")
            assert.are.same("MINUS - nil 1", scanner:scanToken():tostring())
        end)
        it("returns PLUS", function()
            local scanner = LuaScanner.new("+")
            assert.are.same("PLUS + nil 1", scanner:scanToken():tostring())
        end)
        it("returns SEMICOLON", function()
            local scanner = LuaScanner.new(";")
            assert.are.same("SEMICOLON ; nil 1", scanner:scanToken():tostring())
        end)
        it("returns MULT", function()
            local scanner = LuaScanner.new("*")
            assert.are.same("MULT * nil 1", scanner:scanToken():tostring())
        end)
        it("returns DIV", function()
            local scanner = LuaScanner.new("/")
            assert.are.same("DIV / nil 1", scanner:scanToken():tostring())
        end)
        it("returns IDIV", function()
            local scanner = LuaScanner.new("//")
            assert.are.same("IDIV // nil 1", scanner:scanToken():tostring())
        end)
        it("returns BNOT", function()
            local scanner = LuaScanner.new("~")
            assert.are.same("BNOT ~ nil 1", scanner:scanToken():tostring())
        end)
        it("returns NE", function()
            local scanner = LuaScanner.new("~=")
            assert.are.same("NE ~= nil 1", scanner:scanToken():tostring())
        end)
        it("returns L", function()
            local scanner = LuaScanner.new("<")
            assert.are.same("L < nil 1", scanner:scanToken():tostring())
        end)
        it("returns LE", function()
            local scanner = LuaScanner.new("<=")
            assert.are.same("LE <= nil 1", scanner:scanToken():tostring())
        end)
        it("returns G", function()
            local scanner = LuaScanner.new(">")
            assert.are.same("G > nil 1", scanner:scanToken():tostring())
        end)
        it("returns GE", function()
            local scanner = LuaScanner.new(">=")
            assert.are.same("GE >= nil 1", scanner:scanToken():tostring())
        end)
        it("returns ASSIGN", function()
            local scanner = LuaScanner.new("=")
            assert.are.same("ASSIGN = nil 1", scanner:scanToken():tostring())
        end)
        it("returns EQ", function()
            local scanner = LuaScanner.new("==")
            assert.are.same("EQ == nil 1", scanner:scanToken():tostring())
        end)
        it("returns COLON", function()
            local scanner = LuaScanner.new(":")
            assert.are.same("COLON : nil 1", scanner:scanToken():tostring())
        end)
        it("increments line number on \\r or \\n", function()
            -- This is what lua source llex.c does
            -- It increments line number for either \r or \n
            local scanner = LuaScanner.new("\r\n")
            assert.are.same("<eof> nil nil 3", scanner:scanToken():tostring())
        end)
        it("returns COMMENT for single line comments", function()
            local scanner = LuaScanner.new("--comment1\n--comment2")
            assert.are.same("COMMENT --comment1 nil 1", scanner:scanToken():tostring())
            assert.are.same("COMMENT --comment2 nil 2", scanner:scanToken():tostring())
        end)
        it("ignores whitespace ' ', \\f, \\t and \\v", function()
            local scanner = LuaScanner.new(" \f\t\v-- But not in comments")
            assert.are.same("COMMENT -- But not in comments nil 1", scanner:scanToken():tostring())
        end)
        it("returns MULTILINE_COMMENT", function()
            local scanner = LuaScanner.new("--[[comment1\ncomment2]]")
            assert.are.same("MULTILINE_COMMENT --[[comment1\ncomment2]] nil 1", scanner:scanToken():tostring())
            assert.are.same("<eof> nil nil 2", scanner:scanToken():tostring())
        end)
        it("returns DBCOLON", function()
            local scanner = LuaScanner.new("::")
            assert.are.same("DBCOLON :: nil 1", scanner:scanToken():tostring())
        end)
        it("returns CONCAT", function()
            local scanner = LuaScanner.new("..")
            assert.are.same("CONCAT .. nil 1", scanner:scanToken():tostring())
        end)
        it("returns DOTS", function()
            local scanner = LuaScanner.new("...")
            assert.are.same("DOTS ... nil 1", scanner:scanToken():tostring())
        end)
        it("returns MOD", function()
            local scanner = LuaScanner.new("%")
            assert.are.same("MOD % nil 1", scanner:scanToken():tostring())
        end)
        it("returns POW", function()
            local scanner = LuaScanner.new("^")
            assert.are.same("POW ^ nil 1", scanner:scanToken():tostring())
        end)
        it("returns BAND", function()
            local scanner = LuaScanner.new("&")
            assert.are.same("BAND & nil 1", scanner:scanToken():tostring())
        end)
        it("returns BOR", function()
            local scanner = LuaScanner.new("|")
            assert.are.same("BOR | nil 1", scanner:scanToken():tostring())
        end)
        it("returns SHL", function()
            local scanner = LuaScanner.new("<<")
            assert.are.same("SHL << nil 1", scanner:scanToken():tostring())
        end)
        it("returns SHR", function()
            local scanner = LuaScanner.new(">>")
            assert.are.same("SHR >> nil 1", scanner:scanToken():tostring())
        end)
        it("returns STRING", function()
            local scanner = LuaScanner.new("'abc'")
            assert.are.same("STRING 'abc' abc 1", scanner:scanToken():tostring())
        end)
        it("returns STRING with escape character for string", function()
            local scanner = LuaScanner.new("'one\\'two' 'three'")
            assert.are.same("STRING 'one\\'two' one\\'two 1", scanner:scanToken():tostring())
            assert.are.same("STRING 'three' three 1", scanner:scanToken():tostring())
        end)
        it("returns STRING", function()
            local scanner = LuaScanner.new('"abc"')
            assert.are.same('STRING "abc" abc 1', scanner:scanToken():tostring())
        end)
        it("returns STRING", function()
            local scanner = LuaScanner.new("[[one\ntwo]]")
            assert.are.same('STRING [[one\ntwo]] one\ntwo 1', scanner:scanToken():tostring())
        end)
        it("returns REAL for integer numbers", function()
            local scanner = LuaScanner.new("0 1 2 3 4 5 6 7 8 9 01234567890")
            -- note that for some reason implementation call to tonumber return an object that doesn't have ".0" tacked to the end
            assert.are.same('REAL 0 0 1', scanner:scanToken():tostring())
            assert.are.same('REAL 1 1 1', scanner:scanToken():tostring())
            assert.are.same('REAL 2 2 1', scanner:scanToken():tostring())
            assert.are.same('REAL 3 3 1', scanner:scanToken():tostring())
            assert.are.same('REAL 4 4 1', scanner:scanToken():tostring())
            assert.are.same('REAL 5 5 1', scanner:scanToken():tostring())
            assert.are.same('REAL 6 6 1', scanner:scanToken():tostring())
            assert.are.same('REAL 7 7 1', scanner:scanToken():tostring())
            assert.are.same('REAL 8 8 1', scanner:scanToken():tostring())
            assert.are.same('REAL 9 9 1', scanner:scanToken():tostring())
            assert.are.same('REAL 01234567890 1234567890 1', scanner:scanToken():tostring())
        end)
        it("returns REAL for hexadecimals", function()
            local scanner = LuaScanner.new("0x0 0x1 0xdeadBEEF")
            -- note that for some reason implementation call to tonumber return an object that doesn't have ".0" tacked to the end
            assert.are.same('REAL 0x0 0 1', scanner:scanToken():tostring())
            assert.are.same('REAL 0x1 1 1', scanner:scanToken():tostring())
            assert.are.same('REAL 0xdeadBEEF 3735928559 1', scanner:scanToken():tostring())
        end)
        it("returns REAL for decimal numbers", function()
            local scanner = LuaScanner.new("0.0 1.3 .5")
            assert.are.same('REAL 0.0 0.0 1', scanner:scanToken():tostring())
            assert.are.same('REAL 1.3 1.3 1', scanner:scanToken():tostring())
            assert.are.same('REAL .5 0.5 1', scanner:scanToken():tostring())
        end)
        it("returns REAL for exponents", function()
            local scanner = LuaScanner.new("0x2p7 0x2p+7 0x2p-3 2e2 2e+2 2e-2")
            assert.are.same('REAL 0x2p7 256.0 1', scanner:scanToken():tostring())
            assert.are.same('REAL 0x2p+7 256.0 1', scanner:scanToken():tostring())
            assert.are.same('REAL 0x2p-3 0.25 1', scanner:scanToken():tostring())
            assert.are.same('REAL 2e2 200.0 1', scanner:scanToken():tostring())
            assert.are.same('REAL 2e+2 200.0 1', scanner:scanToken():tostring())
            assert.are.same('REAL 2e-2 0.02 1', scanner:scanToken():tostring())
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
