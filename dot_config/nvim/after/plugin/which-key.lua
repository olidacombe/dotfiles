local wk = require("od.which-key")

-- Normal mode mappings
local mappings = {
	{ "b", group = "Buffer" },
	{ "bc", "<Cmd>bd!<CR>", desc = "Close current buffer" },
	{ "bD", "<Cmd>%bd|e#|bd#<CR>", desc = "Delete all buffers" },
	{ "g", group = "Git" },
	{ "gp", "<cmd>Git pull<cr>", desc = "﬇ pull" },
	{ "gC", require("od.git").git_checkout_new_branch, desc = "Create Branch" },
	{
		"gl",
		function()
			vim.cmd.Git("blame")
		end,
		desc = "bLame",
	},
	{ "ll", ":luafile %<CR>", desc = "Run lua file" },
	{ "x", "<cmd>!chmod +x %<CR>", desc = "Make Executable" },
	-- Yank to "+
	{ "y", '"+y', desc = "Yank to Clipboard" },
	{ "Y", '"+Y', desc = "Yank line to Clipboard" },
	{ "<leader>g", ":echo resolve(expand('%:p'))<cr>", desc = "Show full path" },
}

wk.register_normal(mappings)

-- Visual Mode mappings
mappings = {
	-- Replace selection everywhere
	{ "r", 'y:%s/<C-r>"/', desc = "Replace Everywhere" },
	-- Yank to "+
	{ "Y", '"+y', desc = "Yank to Clipboard" },
}

wk.register_visual(mappings)
