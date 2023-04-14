local LuaToken = require "src.LuaToken"

describe("LuaToken", function()
    describe("new()", function()
        it("sets fields", function ()
            local token = LuaToken.new("<number>", "3.14", 3.14, 1)

            assert.are.same("<number>", token.type)
            assert.are.same("3.14", token.lexeme)
            assert.are.same(3.14, token.literal)
            assert.are.same(1, token.line)
        end)
    end)
    describe("token:tostring()", function()
        it("returns a string with its type, lexeme and literal", function ()
            local token = LuaToken.new("<number>", "3.14", 3.14, 1)

            assert.are.same("<number> 3.14 3.14", token:tostring())
        end)
    end)
    describe("tostring(token)", function()
        it("returns a string with its type, lexeme and literal", function ()
            local token = LuaToken.new("<number>", "3.14", 3.14, 1)

            assert.are.same("<number> 3.14 3.14", tostring(token))
        end)
    end)
end)