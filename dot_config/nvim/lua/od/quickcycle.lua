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

local modes = Modes:new({
    { "diagnostic",
        next = "normal ]d", prev = "normal [d" },
    { "harpoon",
        next = require("harpoon.ui").nav_next, prev = require("harpoon.ui").nav_prev },
    { "quickfix",
        next = ":cn", prev = ":cp" }
})

M.mode_next = function()
    modes:inc()
    require('lualine').refresh()
end

M.mode_prev = function()
    modes:dec()
    require('lualine').refresh()
end

M.next = function()
    modes:next()
end

M.prev = function()
    modes:prev()
end

M.get_current = function()
    return modes.current[1]
end

return M
