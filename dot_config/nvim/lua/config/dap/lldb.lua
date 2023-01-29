local dap = require('dap')

local M = {}

M.setup = function()
    local mason_root_dir = require("mason.settings").current.install_root_dir

    dap.adapters.lldb = {
        type = 'server',
        port = "${port}",
        executable = {
            command = mason_root_dir .. "/bin/codelldb",
            args = { '--port', "${port}" },
        },
    }
end

return M
