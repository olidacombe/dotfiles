require "makemapper".setup({
    -- runner = "harpoon_tmux"
})

require("which-key").register({
    m = { name = "make" }
}, { mode = "n", prefix = "<leader>" })
