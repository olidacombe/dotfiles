local M = {}

M.git_checkout_new_branch = function()
    vim.ui.input({
            prompt = "Branch Name",
        },
        function(input)
            if input then
                local without_whitespace = input:gsub("%s+", "_")
                vim.cmd("Git checkout -b " .. without_whitespace)
            end
        end
    )
end

return M
