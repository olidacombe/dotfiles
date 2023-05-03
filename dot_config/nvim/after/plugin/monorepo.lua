local buffer = require("od.buffer")

vim.keymap.set("n", "<leader>fp", function()
    require("telescope").extensions.monorepo.monorepo()
end, { desc = "monorepo project toggle" })
vim.keymap.set("n", "<leader>p", function()
    local path = buffer.current_path():gsub("^" .. vim.fn.getcwd(), ""):gsub("[^/]*$", "")
    require("monorepo").toggle_project(path)
end, { desc = "monorepo project" })
