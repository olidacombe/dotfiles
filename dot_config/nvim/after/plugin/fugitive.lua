-- Git status
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Quick push (TODO use an existing tool better?)
vim.keymap.set("n", "<leader>gp", function () vim.cmd.Git("push origin HEAD") end)

