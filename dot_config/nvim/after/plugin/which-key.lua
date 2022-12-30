local whichkey = require "which-key"
local wk = require "od.which-key"

local conf = {
    window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
    },
}

whichkey.setup(conf)

local yank_to_clipboard = { "\"+y", "Yank to Clipboard" }

-- Normal mode mappings
local mappings = {
    b = {
        name = "Buffer",
        b = { "<cmd>e #<CR>", "Back" },
        c = { "<Cmd>bd!<CR>", "Close current buffer" },
        D = { "<Cmd>%bd|e#|bd#<CR>", "Delete all buffers" },
    },
    p = {
        name = "Project",
        v = { "<cmd>Ex<CR>", "View (netrw)" }
    },
    x = { "<cmd>!chmod +x %<CR>", "Make Executable" },
    -- Yank to "+
    y = yank_to_clipboard,
    Y = { "\"+Y", "Yank line to Clipboard" },
}

wk.register_normal(mappings)

-- Visual Mode mappings
mappings = {
    -- Replace selection everywhere
    r = { 'y:%s/<C-r>"/', "Replace Everywhere" },
    -- Yank to "+
    y = yank_to_clipboard,
}

wk.register_visual(mappings)
