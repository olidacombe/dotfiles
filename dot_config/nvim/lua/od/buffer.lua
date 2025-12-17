local M = {}

M.current_path = function()
    return vim.api.nvim_buf_get_name(0):gsub("^oil://", "")
end

-- Delete buffers by filetype
M.bd_ft = function(ft)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bufnr].filetype == ft then
            vim.api.nvim_buf_delete(bufnr, {})
        end
    end
end

-- Create user command for deleting buffers by filetype
vim.api.nvim_create_user_command("BDFiletype", function(opts)
    local ft = opts.args
    M.bd_ft(ft)
end, { nargs = 1 })

return M
