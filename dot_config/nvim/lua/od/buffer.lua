local M = {}

M.current_path = function()
    return vim.api.nvim_buf_get_name(0):gsub("^oil://", "")
end

return M
