require("makemapper").setup({
    -- runner = "harpoon_tmux"
})

require("which-key").add({
    { "<leader>m", group = "make" },
})
