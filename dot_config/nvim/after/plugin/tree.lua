local wk = require("od.which-key")

require("nvim-tree").setup({
    update_focused_file = {
        enable = true
    }
})

wk.register_normal({
    w = {
        b = { "<cmd>NvimTreeToggle<CR>", "Browser" },
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
        vim.schedule(function()
            -- collapse all a-la-folding
            vim.keymap.set("n", "zM", "<cmd>NvimTreeCollapse<cr>")
        end)
    end,
})
