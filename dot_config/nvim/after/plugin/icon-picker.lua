require("icon-picker").setup({
    disable_legacy_commands = true
})

local os_cb = require('utils').os_cb

local opts = { noremap = true, silent = true, desc = "icon" }

vim.keymap.set("n", "<leader>i", "<cmd>IconPickerNormal<cr>", opts)
os_cb({
    linux = function()
        vim.keymap.set("i", "<A-i>", "<cmd>IconPickerInsert<cr>", opts)
    end,
    darwin = function()
        -- vim.keymap.set("i", "^", "<cmd>IconPickerInsert<cr>", opts)
    end,
})
