--                    ___                       ___           ___
--      ___          /__/\        ___          /  /\         /__/|
--     /  /\         \  \:\      /  /\        /  /:/        |  |:|
--    /  /::\         \  \:\    /  /:/       /  /:/         |  |:|
--   /  /:/\:\    ___  \  \:\  /__/::\      /  /:/  ___   __|  |:|
--  /  /:/~/::\  /__/\  \__\:\ \__\/\:\__  /__/:/  /  /\ /__/\_|:|____
-- /__/:/ /:/\:\ \  \:\ /  /:/    \  \:\/\ \  \:\ /  /:/ \  \:\/:::::/
-- \  \:\/:/__\/  \  \:\  /:/      \__\::/  \  \:\  /:/   \  \::/~~~~
--  \  \::/        \  \:\/:/       /__/:/    \  \:\/:/     \  \:\
--   \__\/          \  \::/        \__\/      \  \::/       \  \:\
--                   \__\/                     \__\/         \__\/
--      ___                       ___                         ___
--     /  /\          ___        /  /\                       /  /\
--    /  /:/         /__/|      /  /:/                      /  /:/_
--   /  /:/         |  |:|     /  /:/       ___     ___    /  /:/ /\
--  /  /:/  ___     |  |:|    /  /:/  ___  /__/\   /  /\  /  /:/ /:/_
-- /__/:/  /  /\  __|__|:|   /__/:/  /  /\ \  \:\ /  /:/ /__/:/ /:/ /\
-- \  \:\ /  /:/ /__/::::\   \  \:\ /  /:/  \  \:\  /:/  \  \:\/:/ /:/
--  \  \:\  /:/     ~\~~\:\   \  \:\  /:/    \  \:\/:/    \  \::/ /:/
--   \  \:\/:/        \  \:\   \  \:\/:/      \  \::/      \  \:\/:/
--    \  \::/          \__\/    \  \::/        \__\/        \  \::/
--     \__\/                     \__\/                       \__\/
--
local M = {}

local Modes = {}

function Modes:new(modes)
    modes = modes or {}
    local i, current = next(modes)
    local o = {
        modes = modes,
        i = i,
        current = current,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Modes:inc()
    local i, v = next(self.modes, self.i)
    if i == nil then
        i, v = next(self.modes)
    end
    self.i = i
    self.current = v
end

function Modes:dec()
    local i = (self.i - 2) % #self.modes + 1
    local v = self.modes[i]
    self.i = i
    self.current = v
end

local cycle_action = function(action)
    local t = type(action)
    if t == "function" then return action() end
    if t == "string" then pcall(vim.cmd, action) end
end

function Modes:next()
    cycle_action(self.current.next)
end

function Modes:prev()
    cycle_action(self.current.prev)
end

-- A stack of modes which might get
-- pushed to for, say, a filetype
-- augroup
local Stack = {}

function Stack:new(modes)
    local o = {
        top = modes,
        stack = { modes },
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Stack:push(modes)
    self.top = modes
    table.insert(self.stack, modes)
end

function Stack:pop()
    table.remove(self.stack)
    self.top = self.stack[#self.stack]
end

local stack = Stack:new(
    Modes:new({
        { "diag",
            next = "normal ]d", prev = "normal [d" },
        { "change",
            next = "normal ]c", prev = "normal [c" },
        { "hrpn",
            next = require("harpoon.ui").nav_next, prev = require("harpoon.ui").nav_prev },
        { "qf",
            next = ":cn", prev = ":cp" }
    })
)

M.new = function(modes)
    return Modes:new(modes)
end

M.mode_next = function()
    stack.top:inc()
    require('lualine').refresh()
end

M.mode_prev = function()
    stack.top:dec()
    require('lualine').refresh()
end

M.push = function(modes)
    stack:push(modes)
    require('lualine').refresh()
end

M.pop = function()
    stack:pop()
    require('lualine').refresh()
end

M.next = function()
    stack.top:next()
end

M.prev = function()
    stack.top:prev()
end

M.get_current = function()
    return stack.top.current[1]
end

return M
