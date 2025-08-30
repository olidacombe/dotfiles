require("icon-picker").setup({
    disable_legacy_commands = true
})

local opts = { noremap = true, silent = true, desc = "icon" }

vim.keymap.set("n", "<leader>i", "<cmd>IconPickerNormal<cr>", opts)
vim.keymap.set("i", "<A-i>", "<cmd>IconPickerInsert<cr>", opts)
