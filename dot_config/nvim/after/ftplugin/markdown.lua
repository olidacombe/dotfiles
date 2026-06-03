--        ,                                                     .  ,
--     ._/),                                                   .(\/),
--     ii// )/)     ,-=-.       ,-=-.       ,-=-.       ,-=-.     (\/|/)
-- ,^=-9 ,//) )=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="/ }/)
--  ""_,),,/ "      ,-=-.       ,-=-.       ,-=-.       ,-=-.      ,/`~
--   """ )))\))=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="
--            <<  <<                             <<   <<
--          ((( >((( >                         ((( > ((( >
--
--                 WIP run bash blocks in markdown files
--        ,                                                     .  ,
--     ._/),                                                   .(\/),
--     ii// )/)     ,-=-.       ,-=-.       ,-=-.       ,-=-.     (\/|/)
-- ,^=-9 ,//) )=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="/ }/)
--  ""_,),,/ "      ,-=-.       ,-=-.       ,-=-.       ,-=-.      ,/`~
--   """ )))\))=-="'     '"=-="'     '"=-="'     '"=-="'     '"=-="
--            <<  <<                             <<   <<
--  gpyy    ((( >((( >                         ((( > ((( >

-- local get_root = function()
--     local parser = vim.treesitter.get_parser()
--     local tree = parser:parse()[1]
--     local root = tree:root()
--     return root
-- end
--
-- -- TODO also validate that it's a ```bash block
-- local get_bash_block = function()
--     local root = get_root()
--     local node = vim.treesitter.get_node()
--     -- P(ts_utils.get_node_text(node, 0))
--     -- if node == nil then
--     --     print("node is nil")
--     --     return nil
--     -- end
--
--     -- Try to find a parent bash block
--     while node:type() ~= "fenced_code_block" do
--         if node == root then
--             return nil
--         end
--         node = node:parent()
--     end
--
--     -- TODO try to find "next" bash block
--
--     for child in node:iter_children() do
--         if child:type() == "code_fence_content" then
--             local text = vim.treesitter.get_node_text(child, 0)
--             return text
--         end
--     end
--     return nil
-- end
--
-- local run_bash_block = function()
--     local block_content = get_bash_block()
--     if block_content == nil then
--         return
--     end
--
--     vim.cmd("vsplit | terminal bash -c \"" .. block_content .. "\"")
--     -- P(block_content)
-- end
--
-- vim.keymap.set("n", "<leader>r", run_bash_block, {
--     desc = "Run markdown bash block",
--     noremap = true,
--     nowait = true,
--     silent = true,
-- })

vim.keymap.set({ "n", "v" }, "<leader>jt", ":JiraTable<CR>", {
    desc = "Create Markdown Table From JQL",
    noremap = true,
    nowait = true,
    silent = true,
})

local function complete_checkbox()
    local line = vim.api.nvim_get_current_line()
    local updated, replacements = line:gsub("⬜", "✅", 1)

    if replacements == 0 then
        vim.notify("No unchecked box on this line", vim.log.levels.WARN)
        return
    end

    vim.api.nvim_set_current_line(updated)
end

vim.keymap.set("n", "<leader>cc", complete_checkbox, {
    desc = "Complete checkbox",
    noremap = true,
    nowait = true,
    silent = true,
    buffer = true,
})

vim.keymap.set("n", "<leader>A", "<Nop>", {
    desc = "AWS"
})

vim.keymap.set("n", "<leader>Ac", ":ShowAwsCostGraphPicker<CR>", {
    desc = "Costs",
    noremap = true,
    nowait = true,
    silent = true,
})

require("od.markdown_sort").setup()

vim.keymap.set("v", "<leader>ms", ":MarkdownSortSections<CR>", {
    desc = "Sort markdown sections",
    noremap = true,
    nowait = true,
    silent = true,
})

require("od.markdown_bash").setup()

vim.keymap.set("n", "<leader>rb", ":MarkdownRunBashBlock<CR>", {
    desc = "Run markdown bash block",
    noremap = true,
    nowait = true,
    silent = true,
})

local function get_slack_config_path()
    if vim.env.XDG_CONFIG_HOME and vim.env.XDG_CONFIG_HOME ~= "" then
        return vim.env.XDG_CONFIG_HOME .. "/slack/config.toml"
    end

    return vim.fn.expand("~/.config/slack/config.toml")
end

local function load_slack_team_ids()
    local ok, lines = pcall(vim.fn.readfile, get_slack_config_path())
    if not ok then
        return {}
    end

    local team_ids = {}
    local section = nil

    for _, line in ipairs(lines) do
        local trimmed = line:match("^%s*(.-)%s*$")
        local next_section = trimmed:match("^%[([%w_.-]+)%]$")

        if next_section then
            section = next_section
        elseif section == "team_ids" then
            local workspace, team_id = trimmed:match('^([%w_-]+)%s*=%s*"([^"]+)"%s*$')
            if workspace and team_id then
                team_ids[workspace] = team_id
            end
        end
    end

    return team_ids
end

local function slack_archive_url_to_deep_link(url)
    local workspace, channel_id, timestamp = url:match("^https://([%w%-]+)%.slack%.com/archives/([^/]+)/p(%d+)")
    if not workspace then
        return nil, "Not a Slack archive URL"
    end

    local team_id = load_slack_team_ids()[workspace]
    if not team_id then
        return nil, ("No Slack team id configured for %s in %s"):format(workspace, get_slack_config_path())
    end

    local seconds = timestamp:sub(1, 10)
    local microseconds = timestamp:sub(11)
    if #seconds ~= 10 or microseconds == "" then
        return nil, "Could not parse Slack message timestamp"
    end

    return ("slack://channel?team=%s&id=%s&message=%s.%s"):format(team_id, channel_id, seconds, microseconds)
end

local function open_first_slack_link()
    local line = vim.api.nvim_get_current_line()
    local error_message = nil

    for _, url in line:gmatch("%[([^%]]+)%]%((https?://[^%)]+)%)") do
        if url:match("^https://[%w%-]+%.slack%.com/") then
            local slack_url, err = slack_archive_url_to_deep_link(url)
            if slack_url then
                local copied, copy_error = pcall(vim.fn.setreg, "+", slack_url)
                if copied then
                    vim.notify("Copied and opening " .. slack_url)
                else
                    vim.notify("Opening " .. slack_url .. "\nCould not copy to clipboard: " .. copy_error,
                        vim.log.levels.WARN)
                end

                vim.ui.open(slack_url)
                return
            end

            error_message = err
        end
    end

    vim.notify(error_message or "No Slack markdown archive link found on this line", vim.log.levels.WARN)
end

local function open_first_markdown_link()
    local line = vim.api.nvim_get_current_line()

    for _, url in line:gmatch("%[([^%]]+)%]%(([^%)]+)%)") do
        vim.ui.open(url)
        return
    end

    vim.notify("No markdown link found on this line")
end

vim.keymap.set("n", "gs", open_first_slack_link, { desc = "open first slack link", buffer = true })
vim.keymap.set("n", "gl", open_first_markdown_link, { desc = "open first link", buffer = true })
