local M = {}

local terminals = {}

M.run = function(cmd)
    if not cmd then return end
    local term_buf = terminals[1]
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        local ok, chan = pcall(vim.api.nvim_buf_get_var, term_buf, 'channel')
        if ok and chan then
            vim.api.nvim_chan_send(chan, cmd .. "\n")
            vim.api.nvim_set_current_buf(term_buf)
            return
        end
    end
    vim.cmd("terminal " .. cmd)
    terminals[1] = vim.api.nvim_get_current_buf()
end

vim.api.nvim_create_user_command(
    'X',
    function(args)
        require("od.terminal").run(args.args)
    end, { desc = "Execute Command in Terminal", nargs = "?" }
)

return M
