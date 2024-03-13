local M = {}

M.branch_name = function()
	return vim.system({ "git", "branch", "--show-current" }, { text = true }):wait().stdout:gsub("[\n\r]", "")
end

M.commit_message_from_branch_name = function(branch_name)
	local message = branch_name:gsub("_", " ")
	message = message:gsub("^%s*", "")
	message = message:gsub("([%d%a]+%-[%d%a%-]+)", "`%1`")
	return message
end

M.git_checkout_new_branch = function(default)
	vim.ui.input({
		prompt = "Branch Name",
		default = default,
	}, function(input)
		if input then
			local without_whitespace = input:gsub("%s+", "_")
			vim.cmd("Git checkout -b " .. without_whitespace)
		end
	end)
end

return M
