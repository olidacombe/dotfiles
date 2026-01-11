local M = {}

M.run_with_progress = function(cmd, opts)
    opts = opts or {}

    local title = opts.title or cmd[1]
    local notify = require("notify")

    -- Show initial progress notification
    local notification = notify(
        opts.message or "Running…",
        "info",
        {
            title = title,
            icon = "⏳",
            timeout = false,
            hide_from_history = false,
        }
    )

    vim.system(cmd, {
        text = true,
        stdout = function(_, data)
            if data then
                notification = notify(
                    data:gsub("\n", ""),
                    "info",
                    {
                        title = title,
                        icon = "⏳",
                        timeout = false,
                        hide_from_history = false,
                        replace = notification,
                    }
                )
            end
        end,
        stderr = function(_, data)
            if data then
                notification = notify(
                    data:gsub("\n", ""),
                    "info",
                    {
                        title = title,
                        icon = "⏳",
                        timeout = false,
                        hide_from_history = false,
                        replace = notification,
                    }
                )
            end
        end,
    }, function(res)
        vim.schedule(function()
            local success = res.code == 0

            notify(
                success and "Done" or "Failed",
                success and "info" or "error",
                {
                    title = title,
                    icon = success and "✓" or "✗",
                    timeout = 2000,
                    replace = notification,
                }
            )

            if success and type(opts.on_success) == "function" then
                opts.on_success(res)
            end
        end)
    end)
end

-- usage
-- run_with_progress({ "git", "fetch" }, { title = "Git fetch" })
-- run_with_progress({ "git", "status" }, { title = "Git status" })

return M
