register_nv = require("od.which-key").register_nv

local mappings = {
    h = {
        name = "Hop / GitSigns",
        l = { "<cmd>HopLine<CR>", "Line" },
        w = { "<cmd>HopWord<CR>", "Word" },
    },
}

register_nv(mappings)
