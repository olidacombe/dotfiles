local whichkey = require("which-key")
local wk = require("od.which-key")

local conf = {
	window = {
		border = "single", -- none, single, double, shadow
		position = "bottom", -- bottom, top
	},
}

whichkey.setup(conf)

local yank_to_clipboard = { '"+y', "Yank to Clipboard" }

-- Normal mode mappings
local mappings = {
	b = {
		name = "Buffer",
		c = { "<Cmd>bd!<CR>", "Close current buffer" },
		D = { "<Cmd>%bd|e#|bd#<CR>", "Delete all buffers" },
	},
	g = {
		name = "Git",
		p = { "<cmd>Git pull<cr>", "﬇ pull" },
		r = { "<cmd>! gh repo view --web<cr>", "-> Repo" },
		C = { require("od.git").git_checkout_new_branch, "Create Branch" },
		l = {
			function()
				vim.cmd.Git("blame")
			end,
			"bLame",
		},
	},
	x = { "<cmd>!chmod +x %<CR>", "Make Executable" },
	-- Yank to "+
	y = yank_to_clipboard,
	Y = { '"+Y', "Yank line to Clipboard" },
}

mappings["<leader>"] = {
	g = { ":echo resolve(expand('%:p'))<cr>", "Show full path" },
}

wk.register_normal(mappings)

-- Visual Mode mappings
mappings = {
	-- Replace selection everywhere
	r = { 'y:%s/<C-r>"/', "Replace Everywhere" },
	-- Yank to "+
	Y = yank_to_clipboard,
}

wk.register_visual(mappings)
