require("nvim-treesitter").setup({
    -- TODO goodnight to this stuff?
    -- incremental_selection = {
    --     enable = true,
    --     keymaps = {
    --         init_selection = "<CR>",
    --         node_Incremental = "<CR>",
    --         scope_incremental = "<S-CR>",
    --         node_decremental = "<BS>",
    --     },
    -- },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    },
})

require("nvim-treesitter").install({ "c", "javascript", "lua", "make", "rust", "toml", "typescript" })

-- fix command window bug caused by using <cr> for incremental selection
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/2634
vim.api.nvim_create_augroup("cmdwin_treesitter", { clear = true })
-- FIXME!!!
-- vim.api.nvim_create_autocmd("CmdwinEnter", {
--     pattern = "*",
--     command = "TSBufDisable incremental_selection",
--     group = "cmdwin_treesitter",
--     desc = "Disable treesitter's incremental selection in Command-line window",
-- })

-- ___  _    ____ _ _ ____ ____ ____ _  _ __ _ ___
-- |--' |___ |--|  Y  |__, |--< [__] |__| | \| |__>
--
require("nvim-treesitter").setup({
    query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
    },
})
vim.keymap.set("n", "<leader>S", "<cmd>InspectTree<cr>", { desc = "Treesitter Playground" })

vim.keymap.set('n', '<CR>', function()
    require('od.treesitter').init_selection()
end, { desc = 'Init treesitter selection' })

vim.keymap.set('v', '<CR>', function()
    require('od.treesitter').node_incremental()
end, { desc = 'Increment node' })

vim.keymap.set('v', '<BS>', function()
    require('od.treesitter').node_decremental()
end, { desc = 'Decrement node' })
