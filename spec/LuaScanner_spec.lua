local LuaScanner = require "src.LuaScanner"

describe("LuaScanner", function()
    describe("new(source)", function()
        it("sets fields", function()
            local scanner = LuaScanner.new("--")

            assert.are.same("--", scanner.source, "source")
            assert.are.same(0, #scanner.tokens, "tokens")
        end)
    end)
    describe("tostring(scanner)", function()
        it("return a literal string", function()
            local scanner = LuaScanner.new("--")

            assert.are.same("LuaScanner", tostring(scanner))
        end)
    end)
end)