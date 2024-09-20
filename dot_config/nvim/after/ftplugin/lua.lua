vim.keymap.set("n", "<leader>ll", ":luafile %<cr>", {
    desc = "Run lua file",
    noremap = true,
    nowait = true,
    silent = true,
})
