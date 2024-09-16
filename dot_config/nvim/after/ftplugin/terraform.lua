vim.keymap.set("n", "<leader><leader>p", ":TerrabastardExtractIamPolicy<cr>", {
    desc = "Extract IAM Policy",
    noremap = true,
    nowait = true,
    silent = true,
})

vim.keymap.set("n", "<leader>p", ":! terraform fmt %<cr>")
