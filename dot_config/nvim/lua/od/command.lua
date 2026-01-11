local M = {}

-- internal helper to create / update notifications
local function notify(msg, level, opts)
    return vim.notify(msg, level, opts)
end

-- Fidget-like API
M.run_with_progress = function(cmd, opts)
    opts = opts or {}

    local title = opts.title or cmd[1]
    local message = opts.message or "Running…"

    -- initial spinner
    local notif_id = notify(message, "info", {
        title = title,
        icon = "󰑓", -- spinner
        timeout = false,
    })

    vim.system(cmd, {
        text = true,
        stdout = function(_, data)
            if data then
                notify(data:gsub("\n", ""), "info", {
                    title = title,
                    replace = notif_id,
                })
            end
        end,
        stderr = function(_, data)
            if data then
                notify(data:gsub("\n", ""), "warn", {
                    title = title,
                    replace = notif_id,
                })
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
                    replace = notif_id,
                    icon = success and "✔" or "✖",
                    timeout = 1500,
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
