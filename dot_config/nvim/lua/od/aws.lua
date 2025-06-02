local function get_cost_data(callback, accounts)
    local json = vim.fn.system({
        'aws', 'ce', 'get-cost-and-usage',
        -- TODO retrieve dates automatically
        '--time-period', 'Start=2025-01-01,End=2025-06-01',
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
        local date = result.TimePeriod.Start
        table.insert(dates, string.format('"%s"', date))
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

-- TODO: move to ftplugin/markdown.lua

vim.keymap.set("n", "<leader>A", "<Nop>", {
    desc = "AWS"
})

vim.keymap.set("n", "<leader>Ac", "<Nop>", {
    desc = "Costs"
})
