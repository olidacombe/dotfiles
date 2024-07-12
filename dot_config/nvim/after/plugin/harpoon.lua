local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

local register_normal = require("od.which-key").register_normal

local os_cb = require("utils").os_cb

local mappings = {
	{ "a", mark.add_file, desc = "Harpoon Mark" },
	{ "e", ui.toggle_quick_menu, desc = "Harpoon List" },
	{ "E", ":Telescope harpoon marks<CR>", desc = "Harpoon Telescope" },
}

register_normal(mappings)

os_cb({
	linux = function()
		vim.keymap.set("n", "<F13>", function()
			ui.nav_file(1)
		end)
		vim.keymap.set("n", "<F14>", function()
			ui.nav_file(2)
		end)
		vim.keymap.set("n", "<F15>", function()
			ui.nav_file(3)
		end)
		vim.keymap.set("n", "<F16>", function()
			ui.nav_file(4)
		end)
	end,
	darwin = function()
		vim.keymap.set("n", "<S-F1>", function()
			ui.nav_file(1)
		end)
		vim.keymap.set("n", "<S-F2>", function()
			ui.nav_file(2)
		end)
		vim.keymap.set("n", "<S-F3>", function()
			ui.nav_file(3)
		end)
		vim.keymap.set("n", "<S-F4>", function()
			ui.nav_file(4)
		end)
	end,
})
-- easy quick-switches :D

-- Switch back from terminal
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>:e #<CR>")
