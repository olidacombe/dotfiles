local dap = require('dap')

local M = {}

M.setup = function()
    local mason_root_dir = require("mason.settings").current.install_root_dir

    dap.adapters.lldb = {
        type = 'server',
        port = '13000',
        executable = {
            command = mason_root_dir .. "/bin/codelldb",
            args = { '--port', '13000' },
        },
    }
end

return M
