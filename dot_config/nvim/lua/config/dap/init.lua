local M = {}

local function configure()
    -- previoulsy called DAPIntsall setup, but now that's a mess
    -- and I have a suspicion Mason.nvim might now take care of it?
    -- https://github.com/Pocco81/dap-buddy.nvim/issues/71#issuecomment-1176926702
end

local function configure_exts()
    require("nvim-dap-virtual-text").setup {
        commented = true,
    }

    local dap, dapui = require "dap", require "dapui"
    dapui.setup {} -- use default
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end

end

local function configure_debuggers()
    -- require("config.dap.lua").setup()
    -- require("config.dap.python").setup()
    -- require("config.dap.rust").setup()
    -- require("config.dap.go").setup()
end

function M.setup()
    configure() -- Configuration
    configure_exts() -- Extensions
    configure_debuggers() -- Debugger
    require("config.dap.keymaps").setup() -- Keymaps
end

configure_debuggers()

return M
