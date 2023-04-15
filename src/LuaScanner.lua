---@class LuaScanner
---@field source string
---@field tokens integer[]
---@field start integer
---@field current integer
---@field line integer
local LuaScanner = {}

local LuaToken = require "LuaToken"

---@return string
function LuaScanner:tostring()
    return string.format("LuaScanner")
end

---@return integer[]
function LuaScanner:scanTokens()
    while not self:isAtEnd() do
        self:scanToken()
    end
    table.insert(self.tokens, LuaToken.new("<eof>", nil, nil, self.line))
    return self.tokens
end

function LuaScanner:scanToken()
    if self:isAtEnd() then return LuaToken.new("<eof>", nil, nil, self.line) end
    local c = self:advance()
    local switch = {
        ['('] = function() return self:addToken("LEFT_PAREN") end,
        [')'] = function() return self:addToken("RIGHT_PAREN") end,
        ['{'] = function() return self:addToken("LEFT_BRACE") end,
        ['}'] = function() return self:addToken("RIGHT_BRACE") end,
        [','] = function() return self:addToken("COMMA") end,
        ['.'] = function()
            return self:addToken(self:matchAny('.') and (self:matchAny('.') and "DOTS" or "CONCAT") or
                "DOT")
        end,
        ['-'] = function()
            if self:matchAny('-') then
                if self:matchMany('[[') then
                    return self:buildMultilineComment()
                else
                    while self:peek() ~= '\r' and self:peek() ~= '\n' and not self:isAtEnd() do
                        self:advance()
                    end
                    local token = self:addToken("COMMENT")
                    token:trimCommentEndline()
                    return token
                end
            else
                return self:addToken("MINUS")
            end
        end,
        ['+'] = function() return self:addToken("PLUS") end,
        [';'] = function() return self:addToken("SEMICOLON") end,
        ['*'] = function() return self:addToken("MULT") end,
        ['%'] = function() return self:addToken("MOD") end,
        ['^'] = function() return self:addToken("POW") end,
        ['&'] = function() return self:addToken("BAND") end,
        ['|'] = function() return self:addToken("BOR") end,
        ['/'] = function() return self:addToken(self:matchAny('/') and "IDIV" or "DIV") end,
        ['~'] = function() return self:addToken(self:matchAny('=') and "NE" or "BNOT") end,
        ['<'] = function() return self:addToken(self:matchAny('<') and "SHL" or (self:matchAny('=') and "LE" or "L")) end,
        ['>'] = function() return self:addToken(self:matchAny('>') and "SHR" or (self:matchAny('=') and "GE" or "G")) end,
        ['='] = function() return self:addToken(self:matchAny('=') and "EQ" or "ASSIGN") end,
        [':'] = function() return self:addToken(self:matchAny(':') and "DBCOLON" or "COLON") end,
        ['\r'] = function()
            self.line = self.line + 1
            self.start = self.current
            while self:matchAny("\r\n") do
                self.line = self.line + 1
                self.start = self.current
            end
            return self:scanToken()
        end,
        ['\n'] = function()
            self.line = self.line + 1
            self.start = self.current
            while self:matchAny("\r\n") do
                self.line = self.line + 1
                self.start = self.current
            end
            return self:scanToken()
        end,
        [' '] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ['\t'] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ['\f'] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ['\v'] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ["'"] = function()
            return self:buildStringToken("'")
        end,
        ['"'] = function()
            return self:buildStringToken('"')
        end,
        ['['] = function()
            if self:matchAny('[') then
                return self:buildStringToken(']]')
            end
        end,
    }
    return (switch[c] or error(string.format("unhandled character %s in token stream at line %d", c, self.line)))()
end

function LuaScanner:buildMultilineComment()
    while not self:isAtEnd() and not self:matchMany(']]') do self:advance() end
    local token = self:addToken("MULTILINE_COMMENT")
    local _, newLineCount = token.lexeme:gsub("[\r\n]", "")
    self.line = self.line + newLineCount
    token:trimCommentEndline()
    return token
end

function LuaScanner:buildStringToken(endChars)
    local line = self.line
    local reachedEnd = false
    while not self:isAtEnd() do
        if self:peek() == '\\' then
            self:advance()
            self:advance()
        elseif self:matchMany(endChars) then
            reachedEnd = true
            break
        else
            if self:peek() == '\r' or self:peek() == '\n' then
                self.line = self.line + 1
            end
            self:advance()
        end
    end
    if not reachedEnd then
        error(string.format("Unterminated string on line %d", line))
    end
    local value = self.source:sub(self.start + #endChars, self.current - #endChars - 1)
    local token = self:addToken("STRING", value, line)
    return token
end

function LuaScanner:skipWhiteSpace()
    while self:matchAny(" \t\v\f") do
    end
    self.start = self.current
end

function LuaScanner:peekMany(expected)
    if self.current + #expected > #self.source then return false end
    for i = 1, #expected do
        if self.source:sub(self.current + i, self.current + i) ~= expected:sub(i, i) then
            return false
        end
    end
    return true
end

---@return string char
function LuaScanner:peek()
    if self:isAtEnd() then return '\0' end
    return self.source:sub(self.current, self.current)
end

---@return string char
function LuaScanner:advance()
    self.current = self.current + 1
    return self.source:sub(self.current - 1, self.current - 1)
end

---@param type string
---@param literal string|nil
---@param line integer|nil
---@return LuaToken token
function LuaScanner:addToken(type, literal, line)
    line = line or self.line
    local text = self.source:sub(self.start, self.current - 1)
    local token = LuaToken.new(type, text, literal, line)
    table.insert(self.tokens, token)
    self.start = self.current
    return token
end

---@param expected string
---@return boolean match
function LuaScanner:matchMany(expected)
    if self.current + #expected > #self.source + 1 then return false end
    for i = 1, #expected do
        if self.source:sub(self.current + i - 1, self.current + i - 1) ~= expected:sub(i, i) then
            return false
        end
    end
    self.current = self.current + #expected
    return true
end

---Advances word window on match
---@param expected string any characters to match
---@return boolean matches
function LuaScanner:matchAny(expected)
    if self:isAtEnd() then return false end
    local char = self:peek()
    local found = expected:find(char, 1, true)
    if found then
        self.current = self.current + 1
    end
    return found ~= nil
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
