require("icon-picker").setup({
    disable_legacy_commands = true
})

local opts = { noremap = true, silent = true, desc = "icon" }

<<<<<<< HEAD
vim.keymap.set("n", "<leader>i", "<cmd>IconPickerNormal<cr>", opts)
vim.keymap.set("i", "<c-i>", "<cmd>IconPickerInsert<cr>", opts)
||||||| parent of 85e9123 (meh)
vim.keymap.set("n", "<leader>i", "<cmd>IconPicker<cr>", opts)
vim.keymap.set("i", "<c-i>", "<cmd>IconPickerInsert<cr>", opts)
=======
-- icoN mappings because c-i does some weird tab thing on macos 🤷
vim.keymap.set("n", "<leader>n", "<cmd>IconPickerNormal<cr>", opts)
vim.keymap.set("i", "<c-n>", "<cmd>IconPickerInsert<cr>", opts)
>>>>>>> 85e9123 (meh)
