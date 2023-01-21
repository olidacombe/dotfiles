local M = {}

local current_mode = "diagnostic"

M.list = function()
    return {
        "diagnostic",
        "harpoon",
        "quickfix",
    }
end

M.next = function()
    -- TODO
end

M.prev = function()
    -- TODO
end

M.get_current = function()
    return current_mode
end

return M
