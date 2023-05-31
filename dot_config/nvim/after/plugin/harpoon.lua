local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

local register_normal = require("od.which-key").register_normal

local mappings = {
	a = { mark.add_file, "Harpoon Mark" },
	e = { ui.toggle_quick_menu, "Harpoon List" },
	E = { ":Telescope harpoon marks<CR>", "Harpoon Telescope" },
}

register_normal(mappings)

-- easy quick-switches :D
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

-- Switch back from terminal
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>:e #<CR>")
