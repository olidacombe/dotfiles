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

local modes = Modes:new({
    "diagnostic",
    "harpoon",
    "quickfix",
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
    -- TODO
end

M.prev = function()
    -- TODO
end

M.get_current = function()
    return modes.current
end

return M
