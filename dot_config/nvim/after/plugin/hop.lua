--  ____________________
-- <  see :h hop-config >
--  --------------------
--   \     .    _  .
--    \    |\_|/__/|
--        / / \/ \  \
--       /__|O||O|__ \
--      |/_ \_/\_/ _\ |
--      | | (____) | ||
--      \/\___/\__/  //
--      (_/         ||
--       |          ||
--       |          ||\
--        \        //_/
--         \______//
--        __ || __||
--       (____(____)
require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

register_nv = require("od.which-key").register_nv

local mappings = {
	{ "h", name = "Hop / GitSigns" },
	{ "hl", "<cmd>HopLine<CR>", desc = "Line" },
	{ "hw", "<cmd>HopWord<CR>", desc = "Word" },
}

register_nv(mappings)
