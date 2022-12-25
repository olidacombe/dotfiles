M = {}

local out = {}

M.plan = function(cb)
    -- TODO TF_CLI_ARGS="-no-color"
    vim.fn.jobstart({ "make", "plan" }, {
        env       = {
            TF_CLI_ARGS = "-no-color",
        },
        on_stdout = function(id, data, _)
            out[id] = out[id] or {}
            for _, v in ipairs(data) do
                table.insert(out[id], v)
            end
        end,
        on_exit   = function(id, _, _)
            cb(out[id])
        end
    })
end

vim.api.nvim_create_user_command(
    'MkPlan',
    function()
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        local line = vim.api.nvim_win_get_cursor(win)[1]
        --local line = vim.api.nvim_get_current_line()
        require("od.terraform").plan(function(out)
            vim.api.nvim_buf_set_lines(buf, line, line, false, out)
        end)
    end, { desc = "Read output of `terraform plan` into buffer" }
)

return M
