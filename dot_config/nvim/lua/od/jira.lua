local async = require("plenary.async.async")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local json = require("json")
local git = require("od.git")

local issue_summary = function(issue)
	return issue["key"] .. ": " .. issue["fields"]["summary"]
end

local jira_issues = function(opts)
	opts = opts or {}
	opts.entry_maker = opts.entry_maker
		or function(entry)
			local issue = json.decode(entry)
			local display = issue_summary(issue)
			return {
				value = issue,
				display = display,
				ordinal = display,
			}
		end
	pickers
		.new(opts, {
			prompt_title = "issues",
			finder = finders.new_oneshot_job({
				"dgira",
				-- TODO args from opts
				-- "-p",
				-- "intg",
			}, opts),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local issue = action_state.get_selected_entry()
					vim.schedule(function()
						git.git_checkout_new_branch(issue.display)
					end)
				end)
				return true
			end,
		})
		:find()
end

-- to execute the function in dev
jira_issues()
