local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

register_normal = require("od.which-key").register_normal

local mappings = {
    a = { mark.add_file, "Harpoon Mark" },
    e = { ui.toggle_quick_menu, "Harpoon List" },
    E = { ":Telescope harpoon marks<CR>", "Harpoon Telescope" },
}
mappings["1"] = { function() ui.nav_file(1) end, "(Harpoon)" }
mappings["2"] = { function() ui.nav_file(2) end, "(Harpoon)" }
mappings["3"] = { function() ui.nav_file(3) end, "(Harpoon)" }
mappings["4"] = { function() ui.nav_file(4) end, "(Harpoon)" }
mappings["5"] = { function() ui.nav_file(5) end, "(Harpoon)" }
mappings["6"] = { function() ui.nav_file(6) end, "(Harpoon)" }
mappings["7"] = { function() ui.nav_file(7) end, "(Harpoon)" }
mappings["8"] = { function() ui.nav_file(8) end, "(Harpoon)" }
mappings["9"] = { function() ui.nav_file(9) end, "(Harpoon)" }

register_normal(mappings)
