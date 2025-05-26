local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- ⛓️ Safe base64 encoding (pure Lua)
local function encode_base64(input)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((input:gsub('.', function(x)
        local r, s = '', x:byte()
        for i = 8, 1, -1 do
            r = r .. (s % 2 ^ i - s % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
        end
        return b:sub(c + 1, c + 1)
    end) .. ({
        '', '==', '='
    })[#input % 3 + 1])
end

-- 🔐 Get config from environment
local function get_env(var)
    local val = os.getenv(var)
    if not val or val == "" then
        error("Environment variable '" .. var .. "' is not set.")
    end
    return val
end

local function get_auth_header()
    local user = get_env("JIRA_USER")
    local token = get_env("JIRA_PASS")
    return "Basic " .. encode_base64(user .. ":" .. token)
end

-- 🔗 URL encode helper
local function urlencode(str)
    if str then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w%-_%.%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = str:gsub(" ", "%%20")
    end
    return str
end

function M.find_field_by_name(name)
    local base_url = get_env("JIRA_HOST")
    local url = base_url .. "/rest/api/3/field"

    Job:new({
        command = "curl",
        args = {
            "-s",
            "-H", "Authorization: " .. get_auth_header(),
            "-H", "Content-Type: application/json",
            url
        },
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val ~= 0 then
                    vim.notify("Failed to fetch Jira fields", vim.log.levels.ERROR)
                    return
                end

                local ok, fields = pcall(vim.json.decode or vim.fn.json_decode, table.concat(j:result(), "\n"))
                if not ok then
                    vim.notify("Failed to decode Jira field response", vim.log.levels.ERROR)
                    return
                end

                local matches = {}
                for _, field in ipairs(fields) do
                    if field.name:lower():find(name:lower(), 1, true) then
                        table.insert(matches, string.format("🔎 %s → `%s`", field.name, field.id))
                    end
                end

                if #matches == 0 then
                    vim.notify("No fields found matching '" .. name .. "'", vim.log.levels.WARN)
                else
                    vim.api.nvim_echo({ { table.concat(matches, "\n"), "Normal" } }, false, {})
                end
            end)
        end
    }):start()
end

-- 🔍 Query Jira using JQL and call `callback(issues)`
function M.query_jira(jql, callback)
    local base_url = get_env("JIRA_HOST")
    local url = base_url .. "/rest/api/3/search?jql=" .. urlencode(jql)

    Job:new({
        command = "curl",
        args = {
            "-s",
            "-H", "Authorization: " .. get_auth_header(),
            "-H", "Content-Type: application/json",
            url
        },
        on_exit = function(j, return_val)
            local result = table.concat(j:result(), "\n")
            vim.schedule(function()
                if return_val ~= 0 then
                    vim.notify("Jira query failed.", vim.log.levels.ERROR)
                    return
                end

                local ok, parsed = pcall(vim.json.decode or vim.fn.json_decode, result)
                if not ok or not parsed then
                    vim.notify("Failed to parse Jira response.", vim.log.levels.ERROR)
                    return
                end

                if parsed.issues then
                    callback(parsed.issues)
                else
                    vim.notify("No issues found.", vim.log.levels.WARN)
                end
            end)
        end,
    }):start()
end

local function safe_field(tbl, field, default)
    default = default or "-"
    return (type(tbl) == "table" and tbl[field]) or default
end

-- 🧭 Telescope picker for Jira issues
function M.jira_picker(jql, callback)
    M.query_jira(jql, function(issues)
        pickers.new({}, {
            prompt_title = "Jira: " .. jql,
            finder = finders.new_table({
                results = issues,
                entry_maker = function(issue)
                    return {
                        value = issue,
                        display = issue.key .. " - " .. issue.fields.summary,
                        ordinal = issue.key .. " " .. issue.fields.summary,
                    }
                end
            }),
            sorter = conf.generic_sorter({}),

            -- 🖼 Rich preview window
            previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry, _)
                    local issue = entry.value
                    local lines = {
                        "🔑 Key: " .. issue.key,
                        "📋 Summary: " .. issue.fields.summary,
                        "📌 Status: " .. issue.fields.status.name,
                        "👤 Assignee: " .. safe_field(issue.fields.assignee, "displayName", "Unassigned"),
                        "🕒 Updated: " .. issue.fields.updated,
                        "🌐 URL: " .. get_env("JIRA_HOST") .. "/browse/" .. issue.key,
                        "",
                        "🧾 Description:"
                    }

                    local desc = "No description"
                    local description = issue.fields.description

                    if type(description) == "table" then
                        local content = description.content or {}
                        local chunks = {}

                        for _, block in ipairs(content) do
                            if block.content then
                                for _, part in ipairs(block.content) do
                                    if part.text then
                                        table.insert(chunks, part.text)
                                    end
                                end
                            end
                        end

                        if #chunks > 0 then
                            desc = table.concat(chunks, " ")
                        end
                    elseif type(description) == "string" and description ~= "" then
                        -- Handle legacy plain-text descriptions
                        desc = description
                    end

                    for _, line in ipairs(vim.split(desc, "\n", { plain = true })) do
                        table.insert(lines, "  " .. line)
                    end

                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                    vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
                end
            }),

            attach_mappings = callback,

        }):find()
    end)
end

local table_callback = function(from_line, to_line)
    if from_line == nil then
        from_line = vim.api.nvim_win_get_cursor(0)[1] - 1
    end
    if to_line == nil then
        to_line = from_line + 1
    end
    return function(prompt_bufnr)
        actions.select_default:replace(function()
            local picker = action_state.get_current_picker(prompt_bufnr)
            local selections = picker:get_multi_selection()

            if vim.tbl_isempty(selections) then
                table.insert(selections, action_state.get_selected_entry())
            end

            actions.close(prompt_bufnr)

            local lines = {
                "| Key | Status | RAG | Priority | Summary | Due Date | Description | Assignee | Business Team | Updated |",
                "|:----|:--------|:----|:----------|:---------|:----------|:-------------|:----------|:---------|"
            }

            for _, entry in ipairs(selections) do
                local issue = entry.value
                local fields = issue.fields

                local key = issue.key
                local url = get_env("JIRA_HOST") .. "/browse/" .. key
                local key_link = string.format("[%s](%s)", key, url)

                local status = fields.status and fields.status.name or ""
                local rag = safe_field(fields.customfield_10286, "value")
                local priority = safe_field(fields.priority, "name")

                local summary = fields.summary:gsub("|", "\\|")
                if #summary > 50 then
                    summary = summary:sub(1, 47) .. "..."
                end

                local due = fields.duedate or "—"
                if due == vim.NIL then
                    due = "—"
                end
                local assignee = safe_field(fields.assignee, "displayName", "Unassigned")
                local business_team = (fields.customfield_10978 or { value = "—" })
                    .value -- Update this field name to match your Business Team
                local updated = fields.updated or "—"

                -- Description (flatten first paragraph)
                local description = "—"
                local d = fields.description
                if type(d) == "table" and d.content then
                    local chunks = {}
                    for _, block in ipairs(d.content) do
                        if block.content then
                            for _, part in ipairs(block.content) do
                                if part.text then
                                    table.insert(chunks, part.text)
                                end
                            end
                        end
                        if #chunks > 0 then break end
                    end
                    if #chunks > 0 then
                        description = table.concat(chunks, " "):gsub("|", "\\|")
                        if #description > 50 then
                            description = description:sub(1, 47) .. "..."
                        end
                    end
                elseif type(d) == "string" then
                    description = #d > 50 and d:sub(1, 47) .. "..." or d
                end

                -- Markdown row
                table.insert(lines, string.format(
                    "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |",
                    key_link, status, rag, priority, summary, due, description, assignee, business_team, updated
                ))
            end

            -- Insert table at given lines
            vim.api.nvim_buf_set_lines(0, from_line, to_line, false, lines)
        end)
        return true
    end
end

vim.api.nvim_create_user_command("JiraFindField", function(opts)
    require("od.jira").find_field_by_name(opts.args)
end, {
    nargs = 1,
    desc = "Search for Jira field IDs by name (e.g. :JiraFindField RAG)"
})

vim.api.nvim_create_user_command("JiraTable", function(opts)
    local from_line = opts.line1
    local to_line = opts.line2

    local lines = vim.api.nvim_buf_get_lines(0, from_line - 1, to_line, false)
    local line_content = table.concat(lines, " ")

    require("od.jira").jira_picker(line_content, table_callback(from_line - 1, to_line))
end, {
    range = true,
    desc = "Create Markdown Table From JQL",
})

return M
