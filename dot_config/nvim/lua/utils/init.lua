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
    if cb then
        cb()
    end
end

-- local function region_to_text(region)
--     local text = ""
--     local maxcol = vim.v.maxcol
--     for line, cols in vim.spairs(region) do
--         local endcol = cols[2] == maxcol and -1 or cols[2]
--         local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
--         text = ("%s%s\n"):format(text, chunk)
--     end
--     return text
-- end

function M.get_current_visual_selection()
    -- local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
    -- local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
    -- P(r)
    -- return region_to_text(r)
    get_visual_selection()
end

-- https://github.com/neovim/neovim/pull/13896 ?
local function get_visual_selection()
    local s_start_row, s_start_col = table.unpack(vim.api.nvim_buf_get_mark(0, "<"))
    local s_end_row, s_end_col = table.unpack(vim.api.nvim_buf_get_mark(0, ">"))
    local n_lines = math.abs(s_end_row - s_start_row) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start_row - 1, s_end_row, false)
    lines[1] = string.sub(lines[1], s_start_col, -1)
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end_col)
    P(lines)
    return table.concat(lines, "\n")
end

return M

vim.keymap.set("v", "V", ":lua P(get_visual_selection())<cr>:messages<cr>")
