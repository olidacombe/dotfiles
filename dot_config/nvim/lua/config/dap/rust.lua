local dap = require('dap')

local M = {}

M.setup = function()
    dap.configurations.rust = {
        {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
                vim.fn.jobstart('cargo build')
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
            end,
            args = function()
                local args = {}
                vim.ui.input({
                        prompt = "Args: ",
                    },
                    function(input)
                        if input then
                            for arg in input:gmatch("%S+") do
                                table.insert(args, arg)
                            end
                        end
                    end)
                return args
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            -- 💀
            -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
            --
            --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
            --
            -- Otherwise you might get the following error:
            --
            --    Error on launch: Failed to attach to the target process
            --
            -- But you should be aware of the implications:
            -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
            -- runInTerminal = false,
        },
    }
end

-- work on the above arg parser here - get quotes and escapes please
-- local args = {}
-- vim.ui.input({
--     prompt = "oi: ",
-- }, function(input)
--     if input then
--         for arg in input:gmatch("%S+") do
--             table.insert(args, arg)
--         end
--     end
-- end)
-- P(args)

return M
