-- local null_ls = require('null-ls')
require("crates").setup({
	popup = {
		autofocus = true,
		-- hide_on_select = false,
	},
	null_ls = {
		enabled = true,
		name = "crates.nvim",
	},
})
