register_normal = require("od.which-key").register_normal

-- key mappings
local mappings = {
	{ "z", name = "Lazy" },
	{ "zi", "<cmd>Lazy install<cr>", desc = "Install" },
	{ "zs", "<cmd>Lazy sync<cr>", desc = "Sync" },
	{ "zu", "<cmd>Lazy update<cr>", desc = "Update" },
}

register_normal(mappings)
