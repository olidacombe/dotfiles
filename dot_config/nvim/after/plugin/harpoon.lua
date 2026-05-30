local harpoon = require("harpoon")

local register_normal = require("od.which-key").register_normal

local mappings = {
    { "a", function() harpoon:list():add() end,                         desc = "Harpoon Mark" },
    { "e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon List" },
    { "E", ":Telescope harpoon marks<CR>",                              desc = "Harpoon Telescope" },
}

register_normal(mappings)

vim.keymap.set("n", "<F13>", function()
    harpoon:list():select(4)
end)
vim.keymap.set("n", "<C-M-S-j>", function()
    harpoon:list():select(4)
end)
vim.keymap.set("n", "<F14>", function()
    harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-M-S-h>", function()
    harpoon:list():select(3)
end)
vim.keymap.set("n", "<F15>", function()
    harpoon:list():select(2)
end)
-- I don't know why <F15> is being sent as <S-F3> on some machines 🤔
vim.keymap.set("n", "<S-F3>", function()
    harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-M-S-k>", function()
    harpoon:list():select(2)
end)
-- Deal with a ghostty / tmux 3.6a quirk making me lose <F15> on some builds 🤷
vim.keymap.set("n", '<Esc>[13;2~', function() harpoon:list():select(2) end)

vim.keymap.set("n", "<F16>", function()
    harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-M-S-l>", function()
    harpoon:list():select(1)
end)
-- easy quick-switches :D

-- Switch back from terminal
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>:e #<CR>")
