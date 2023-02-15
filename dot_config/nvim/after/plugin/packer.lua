register_normal = require("od.which-key").register_normal

-- key mappings
local mappings = {
    z = {
        name = "Lazy",
        i = { "<cmd>Lazy install<cr>", "Install" },
        s = { "<cmd>Lazy sync<cr>", "Sync" },
        u = { "<cmd>Lazy update<cr>", "Update" },
    },
}

register_normal(mappings)
