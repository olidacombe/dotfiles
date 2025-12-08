local Job = require("plenary.job")
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
            Job:new({
                command = "refalizer",
                args = { input },
                on_exit = function(j, _)
                    Job:new({
                        command = "git",
                        args = {
                            "checkout",
                            "-b",
                            j:result()[1],
                        },
                    }):start()
                end,
            }):start()
        end
    end)
end

-- Delete buffers by filetype
M.bd_ft = function(ft)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bufnr].filetype == ft then
            vim.api.nvim_buf_delete(bufnr, {})
        end
    end
end

-- Create user command for deleting buffers by filetype
vim.api.nvim_create_user_command("BDFiletype", function(opts)
    local ft = opts.args
    M.bd_ft(ft)
end, { nargs = 1 })

return M
