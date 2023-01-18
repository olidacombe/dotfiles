vim.g.mapleader = " "

-- Slide visual selections around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Tab Nav
vim.keymap.set("n", "<Tab>", ":tabn<CR>")
vim.keymap.set("n", "<S-Tab>", ":tabp<CR>")

-- Fold Nav
vim.keymap.set("n", "<Left>", "zc")
vim.keymap.set("n", "<Right>", "zo")
vim.keymap.set("n", "<leader><Left>", "zC")
vim.keymap.set("n", "<leader><Right>", "zO")
vim.keymap.set("n", "<Up>", "zk")
vim.keymap.set("n", "<Down>", "zj")
-- vim.keymap.set("n", "<S-Up>", "[z")
-- vim.keymap.set("n", "<S-Down>", "]z")

-- Quickfix Nav - too much?
vim.keymap.set("n", "`", ":cp<CR>")
vim.keymap.set("n", '"', ":cn<CR>")

-- All else has moved to `which-key.lua`
