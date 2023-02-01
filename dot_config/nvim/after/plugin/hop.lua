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
require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }

register_nv = require("od.which-key").register_nv

local mappings = {
    h = {
        name = "Hop / GitSigns",
        l = { "<cmd>HopLine<CR>", "Line" },
        w = { "<cmd>HopWord<CR>", "Word" },
    },
}

register_nv(mappings)
