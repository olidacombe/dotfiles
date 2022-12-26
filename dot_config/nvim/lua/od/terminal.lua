local term = require("harpoon.term")

M = {}

local out = {}

M.run = function(cmd)
    if cmd then
        term.sendCommand(1, cmd .. "\n")
        term.gotoTerminal(1)
    end
end

vim.api.nvim_create_user_command(
    'X',
    function(args)
        require("od.terminal").run(args.args)
    end, { desc = "Execute Command in Terminal", nargs = "?" }
)

return M
