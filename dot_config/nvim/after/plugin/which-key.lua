whichkey = require "which-key"

conf = {
    window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
    },
}

whichkey.setup(conf)

-- Start with Normal Mode mappings
opts = {
    mode = "n", -- Normal mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false, -- use `nowait` when creating keymaps
}

yank_to_clipboard = { "\"+y", "Yank to Clipboard" }

mappings = {
    b = {
        name = "Buffer",
        c = { "<Cmd>bd!<Cr>", "Close current buffer" },
        D = { "<Cmd>%bd|e#|bd#<Cr>", "Delete all buffers" },
    },
    t = {
        name = "Test / Tab",
        c = { "<cmd>tabc<CR>", "Tab Close" },
        f = { "<cmd>TestFile<CR>", "Test File" },
        n = { "<cmd>TestNearest<CR>", "Test Nearest" },
        s = { "<cmd>TestSuite<CR>", "Test Suite" },
    },
    g = {
        name = "Git",
        s = { "<cmd>Git<CR>", "Status" },
        D = { "<cmd>DiffviewOpen<CR>", "Diff" },
    },
    h = {
        name = "Hop",
        l = { "<cmd>HopLine<CR>", "Line" },
        w = { "<cmd>HopWord<CR>", "Word" },
    },
    p = {
        name = "Project",
        v = { "<cmd>Ex<CR>", "View (netrw)" }
    },
    u = { "<cmd>UndotreeToggle<CR>", "Undo Tree" },
    x = { "<cmd>!chmod +x %<CR>", "Make Executable" },
    -- Yank to "+
    y = yank_to_clipboard,
    Y = { "\"+Y", "Yank line to Clipboard" },
    z = {
        name = "Packer",
        c = { "<cmd>PackerCompile<cr>", "Compile" },
        i = { "<cmd>PackerInstall<cr>", "Install" },
        s = { "<cmd>PackerSync<cr>", "Sync" },
        S = { "<cmd>PackerStatus<cr>", "Status" },
        u = { "<cmd>PackerUpdate<cr>", "Update" },
    },

}

whichkey.register(mappings, opts)

-- Visual Mode mappings
opts.mode = "v"

mappings = {
    -- Replace selection everywhere
    r = { 'y:%s/<C-r>"/', "Replace Everywhere" },
    -- Yank to "+
    y = yank_to_clipboard,
}

whichkey.register(mappings, opts)
