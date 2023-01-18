local wk = require("od.which-key")
local collapse_all = require("nvim-tree.actions.tree-modifiers.collapse-all").fn
local expand_all = require("nvim-tree.actions.tree-modifiers.expand-all").fn

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
                { key = "zM", action = "Collapse", action_cb = function(node)
                    collapse_all()
                end },
                { key = "zR", action = "Expand", action_cb = function(node)
                    expand_all(node)
                end },
            },
        },
    },
})

wk.register_normal({
    w = {
        b = { "<cmd>NvimTreeToggle<CR>", "Browser" },
    },
})
