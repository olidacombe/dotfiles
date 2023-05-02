vim.keymap.set("n", "<leader>fp", function()
    require("telescope").extensions.monorepo.monorepo()
end, { desc = "monorepo project toggle" })
vim.keymap.set("n", "<leader>p", function()
    local path = vim.api.nvim_buf_get_name(0):gsub("^oil://", ""):gsub("^" .. vim.fn.getcwd(), "")
    require("monorepo").toggle_project(path)
end, { desc = "monorepo project" })
