register_normal = require("od.which-key").register_normal

local mappings = {
    u = { "<cmd>UndotreeToggle<CR>", "Undo Tree" },
}

register_normal(mappings)
