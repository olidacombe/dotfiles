local wk = require("od.which-key")

require("nvim-tree").setup({
    update_focused_file = {
        enable = true
    },
    view = {
        mappings = {
            custom_only = false,
            list = {
                -- allow tab to fall through to my default
                { key = "<Tab>", action = "" },
                -- use + as inverse of - (dir_up)
                { key = "+", action = "cd" },
            },
        },
    },
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
