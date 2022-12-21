vim.g["test#strategy"] = "harpoon"

register_normal = require("od.which-key").register_normal

local mappings = {
    t = {
        name = "Test / Tab",
        c = { "<cmd>tabc<CR>", "Tab Close" },
        f = { "<cmd>TestFile<CR>", "Test File" },
        n = { "<cmd>TestNearest<CR>", "Test Nearest" },
        s = { "<cmd>TestSuite<CR>", "Test Suite" },
    },
}

register_normal(mappings)
