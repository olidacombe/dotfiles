register_normal = require("od.which-key").register_normal

local mappings = {
    h = {
        name = "Hop",
        l = { "<cmd>HopLine<CR>", "Line" },
        w = { "<cmd>HopWord<CR>", "Word" },
    },
}

register_normal(mappings)
