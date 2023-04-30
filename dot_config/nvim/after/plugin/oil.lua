require("oil").setup({
    default_file_explorer = true,
    -- keymaps = {
    --     ["g?"] = "actions.show_help",
    --     ["<CR>"] = "actions.select",
    --     ["<C-s>"] = "actions.select_vsplit",
    --     ["<C-h>"] = "actions.select_split",
    --     ["<C-t>"] = "actions.select_tab",
    --     ["<C-p>"] = "actions.preview",
    --     ["<C-c>"] = "actions.close",
    --     ["<C-l>"] = "actions.refresh",
    --     ["-"] = "actions.parent",
    --     ["_"] = "actions.open_cwd",
    --     ["`"] = "actions.cd",
    --     ["~"] = "actions.tcd",
    --     ["g."] = "actions.toggle_hidden",
    -- },
    restore_win_options = true,
    silence_disclaimer = true,
    skip_confirm_for_simple_edits = false,
    view_options = {
        show_hidden = false,
    }
})
