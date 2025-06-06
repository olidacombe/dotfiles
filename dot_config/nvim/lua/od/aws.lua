local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local Job = require('plenary.job')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local action_set = require('telescope.actions.set')

local M = {}

local function get_yesterdays_date()
    return os.date("%Y-%m-%d", os.time() - 86400)
end

local function first_day_six_months_ago()
    local now = os.date("*t")
    local year = now.year
    local month = now.month - 6

    if month <= 0 then
        month = month + 12
        year = year - 1
    end

    return string.format("%04d-%02d-01", year, month)
end

local function get_cost_data(callback, accounts)
    local json = vim.fn.system({
        'aws', 'ce', 'get-cost-and-usage',
        '--time-period', string.format('Start=%s,End=%s', first_day_six_months_ago(), get_yesterdays_date()),
        '--granularity', 'MONTHLY',
        '--filter', string.format([[
            {
                "Dimensions": {
                    "Key": "LINKED_ACCOUNT",
                    "Values": ["%s"]
                }
            }
        ]], table.concat(accounts, '","')),
        '--metrics', 'AmortizedCost',
        '--output', 'json'
    })

    local ok, parsed = pcall(vim.fn.json_decode, json)
    if not ok or not parsed then
        vim.notify("Failed to get cost data", vim.log.levels.ERROR)
        return
    end
    callback(parsed)
end

local function cost_data_to_mermaid(cost_data)
    local diagram = { "```mermaid", "xychart-beta" }

    local dates = {}

    for _, result in ipairs(cost_data.ResultsByTime) do
        local month = result.TimePeriod.Start:sub(1, 7)
        table.insert(dates, string.format('"%s"', month))
    end

    table.insert(diagram, string.format('  x-axis "Month" [%s]', table.concat(dates, ", ")))

    local amounts = {}

    for _, result in ipairs(cost_data.ResultsByTime) do
        local amount = result.Total.AmortizedCost.Amount
        table.insert(amounts, amount)
    end

    table.insert(diagram,
        string.format('  y-axis "Cost (USD)" 0 --> %s', math.max(table.unpack(amounts))))

    table.insert(diagram, string.format('  bar [%s]', table.concat(amounts, ", ")))

    table.insert(diagram, "```")
    return diagram
end

vim.api.nvim_create_user_command("ShowAwsCostGraph", function(args)
    get_cost_data(function(data)
        local graph = cost_data_to_mermaid(data)
        local buf = vim.api.nvim_get_current_buf()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(buf, current_line, current_line, false, graph)
    end, args.fargs)
end, { desc = "Show AWS Cost Graph", nargs = '+' })

function M.aws_account_picker(opts, callback)
    opts = opts or {}

    Job:new({
        command = "aws",
        args = { "organizations", "list-accounts", "--output", "json" },
        on_exit = function(j, _)
            vim.schedule(function()
                local output = table.concat(j:result(), "\n")
                local decoded = vim.fn.json_decode(output)
                local entries = {}

                for _, acct in ipairs(decoded.Accounts or {}) do
                    local line = string.format("%s\t%s", acct.Id, acct.Name)
                    table.insert(entries, line)
                end

                pickers.new(opts, {
                    prompt_title = "Select AWS Accounts",
                    finder = finders.new_table {
                        results = entries,
                    },
                    sorter = conf.generic_sorter(opts),
                    attach_mappings = function(prompt_bufnr, map)
                        action_set.select:replace(function()
                            local picker = action_state.get_current_picker(prompt_bufnr)
                            local selections = picker:get_multi_selection()
                            if vim.tbl_isempty(selections) then
                                selections = { action_state.get_selected_entry() }
                            end

                            local account_ids = {}
                            for _, item in ipairs(selections) do
                                local id = item[1]:match("^(%d+)")
                                table.insert(account_ids, id)
                            end

                            actions.close(prompt_bufnr)

                            callback(account_ids)
                        end)
                        return true
                    end,
                }):find()
            end)
        end,
    }):start()
end

vim.api.nvim_create_user_command("ShowAwsCostGraphPicker", function()
    M.aws_account_picker({}, function(accounts)
        if #accounts == 0 then
            vim.notify("No accounts selected", vim.log.levels.WARN)
            return
        end
        get_cost_data(function(data)
            local graph = cost_data_to_mermaid(data)
            local buf = vim.api.nvim_get_current_buf()
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_buf_set_lines(buf, current_line, current_line, false, graph)
        end, accounts)
    end)
end, { desc = "Show AWS Cost Graph" })
