local wk = require("od.which-key")
local run_with_fidget = require("od.command").run_with_fidget

-- Normal mode mappings
local mappings = {
    { "b",  group = "Buffer" },
    { "bc", "<Cmd>bd!<CR>",        desc = "Close current buffer" },
    { "bD", "<Cmd>%bd|e#|bd#<CR>", desc = "Delete all buffers" },
    { "p",  group = "Path" },
    {
        "pr",
        function()
            local path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
            vim.fn.setreg("+", path)
            vim.notify("Copied relative path: " .. path)
        end,
        desc = "Copy Relative Path",
    },
    {
        "pa",
        function()
            local path = vim.fn.resolve(vim.fn.expand("%:p"))
            vim.fn.setreg("+", path)
            vim.notify("Copied full path: " .. path)
        end,
        desc = "Copy Full Path",
    },
    { "g", group = "Git" },
    { "gp", "<cmd>G! pull<cr>", desc = "﬇ pull" },
    { "gp", function() run_with_fidget({ "git", "pull" }, { title = "git pull" }) end, desc = "﬇ pull" },
    { "gC", require("od.git").git_checkout_new_branch, desc = "Create Branch" },
    {
        "gl",
        function()
            vim.cmd.Git("blame")
        end,
        desc = "bLame",
    },
    { "<leader>x", "<cmd>!chmod +x %<CR>",             desc = "Make Executable" },
    -- Yank to "+
    { "y",         '"+y',                              desc = "Yank to Clipboard" },
    { "Y",         '"+Y',                              desc = "Yank line to Clipboard" },
    { "<leader>g", ":echo resolve(expand('%:p'))<cr>", desc = "Show full path" },
}

wk.register_normal(mappings)

-- Visual Mode mappings
mappings = {
    -- Replace selection everywhere
    { "r", 'y:%s/<C-r>"/', desc = "Replace Everywhere" },
    -- Yank to "+
    { "Y", '"+y',          desc = "Yank to Clipboard" },
}

wk.register_visual(mappings)
