-- Quick jump to netrw
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Slide visual selections around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Yank direct to clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Replace selection everywhere
vim.keymap.set("v", "<leader>r", 'y:%s/<C-r>"/')

-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
