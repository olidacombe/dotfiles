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

return M
