require("mini.ai").setup()
-- require("mini.comment").setup()
local hipatterns = require("mini.hipatterns")
local pairs = require("mini.pairs")
require("mini.splitjoin").setup()
require("mini.surround").setup()

-- Surround convenience
-- see [here](https://github.com/echasnovski/mini.surround/blob/9d1956b576d7051da3a483b251dfc778121c60db/lua/mini/surround.lua#L486-L486)
require("which-key").register({
	s = { name = "surround", w = { "saiw", "word" }, W = { "saiW", "Word" } },
}, {
	mode = "n",
	remap = true,
})

hipatterns.setup({
	highlighters = {
		-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
		fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
		hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
		todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
		note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

		-- Highlight hex color strings (`#rrggbb`) using that color
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})

pairs.setup({
	mappings = {
		["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
		["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
		["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
		["<"] = { action = "open", pair = "<>", neigh_pattern = "[^%s\\]." },

		[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
		["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
		["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
		[">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },

		['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
		["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a<&\\].", register = { cr = false } },
		["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
	},
})
