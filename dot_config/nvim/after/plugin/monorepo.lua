local buffer = require("od.buffer")
local monorepo = require("monorepo")

local function go_to_project(path)
    monorepo.go_to_project(require("monorepo.utils").index_of(monorepo.monorepoVars[monorepo.currentMonorepo], path))
end

vim.keymap.set("n", "<leader>fp", function()
    require("telescope").extensions.monorepo.monorepo()
end, { desc = "monorepo project toggle" })
vim.keymap.set("n", "<leader>p", function()
    local path = buffer.current_path():sub(monorepo.currentMonorepo:len() + 1):gsub("[^/]*$", "")
    monorepo.add_project(path)
    go_to_project(path)
end, { desc = "monorepo project" })
vim.keymap.set("n", "<leader>P", function()
    go_to_project("/")
    P("Loaded root project.")
end, { desc = "monorepo root" })
