local M = {}

function M.is_empty(s)
    return s == nil or s == ""
end

-- take a table of callbacks, e.g.
-- local bla = {
--     linux = function() print("I am linux") end,
--     darwin = function() print("I am macos") end,
-- }
-- and run the corresponding callback for the
-- current os if it exists
function M.os_cb(callbacks)
    local os = vim.loop.os_uname().sysname:lower()
    local cb = callbacks[os]
    if cb then cb() end
end

-- cursor-stashing wrapper for a function.
-- The cursor position is restored after the function is called,
-- even if it errors.
function M.stash_cursor(f)
    return function(...)
        local cursor = vim.api.nvim_win_get_cursor(0)
        local ok, err = pcall(f, ...)
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
        if not ok then error(err, 2) end
    end
end

return M
