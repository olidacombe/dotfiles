require("icon-picker").setup({
    disable_legacy_commands = true
})

local opts = { noremap = true, silent = true, desc = "icon" }

-- icoN mappings because c-i does some weird tab thing on macos 🤷
vim.keymap.set("n", "<leader>n", "<cmd>IconPickerNormal<cr>", opts)
vim.keymap.set("i", "<c-n>", "<cmd>IconPickerInsert<cr>", opts)
