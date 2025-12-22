local M = {}

M.run_with_fidget = function(cmd, opts)
    opts = opts or {}

    local handle = require("fidget.progress").handle.create({
        title = opts.title or cmd[1],
        message = opts.message or "Running…",
    })

    vim.system(cmd, {
        text = true,
        stdout = function(_, data)
            if data then
                handle:report({ message = data:gsub("\n", "") })
            end
        end,
        stderr = function(_, data)
            if data then
                handle:report({ message = data:gsub("\n", "") })
            end
        end,
    }, function(res)
        vim.schedule(function()
            local success = res.code == 0

            handle:report({
                message = success and "Done" or "Failed",
            })
            handle:finish()

            if success and type(opts.on_success) == "function" then
                opts.on_success(res)
            end
        end)
    end)
end

-- usage
-- run_with_fidget({ "git", "fetch" }, { title = "Git fetch" })
-- run_with_fidget({ "git", "status" }, { title = "Git status" })

return M
