vim.g["test#strategy"] = "harpoon"

vim.keymap.set("n", "<leader>tf", vim.cmd.TestFile)
vim.keymap.set("n", "<leader>tn", vim.cmd.TestNearest)
vim.keymap.set("n", "<leader>ts", vim.cmd.TestSuite)
