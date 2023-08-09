local mark = require("harpoon.mark")
local oil = require("oil")

oil.setup({
	default_file_explorer = true,
	keymaps = {
		["g?"] = "actions.show_help",
		["<CR>"] = "actions.select",
		["<C-s>"] = "actions.select_vsplit",
		["<C-h>"] = false, -- "actions.select_split",
		["<C-t>"] = "actions.select_tab",
		["<C-p>"] = "actions.preview",
		["<C-c>"] = "actions.close",
		["<C-l>"] = false, -- "actions.refresh",
		["-"] = "actions.parent",
		["_"] = "actions.open_cwd",
		["`"] = "actions.cd",
		["~"] = "actions.tcd",
		["g."] = "actions.toggle_hidden",
		["<leader>a"] = {
			callback = function()
				local entry = oil.get_cursor_entry()
				if not entry or entry.type ~= "file" then
					return
				end
				local dir = oil.get_current_dir()
				mark.add_file(dir .. entry.name)
			end,
			desc = ">>harpoon",
			silent = true,
			noremap = true,
			nowait = true,
		},
	},
	restore_win_options = true,
	silence_disclaimer = true,
	skip_confirm_for_simple_edits = false,
	view_options = {
		show_hidden = true,
	},
})
