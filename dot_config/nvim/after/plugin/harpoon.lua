local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

local register_normal = require("od.which-key").register_normal

local mappings = {
    a = { mark.add_file, "Harpoon Mark" },
    e = { ":Telescope harpoon marks<CR>", "Harpoon Telescope" },
    E = { ui.toggle_quick_menu, "Harpoon List" },
    X = { function()
        vim.ui.input({
            prompt = "Command: ",
        }, function(input)
            if input then
                vim.api.nvim_command(":X " .. input)
            else
                print "Command cancelled"
            end
        end)
    end, "Execute in Terminal" },
}
mappings["0"] = { function() ui.nav_file(1) end, "(Harpoon)" }
mappings["1"] = { function() ui.nav_file(2) end, "(Harpoon)" }
mappings["2"] = { function() ui.nav_file(3) end, "(Harpoon)" }
mappings["3"] = { function() ui.nav_file(4) end, "(Harpoon)" }
mappings["4"] = { function() ui.nav_file(5) end, "(Harpoon)" }
mappings["5"] = { function() ui.nav_file(6) end, "(Harpoon)" }
mappings["6"] = { function() ui.nav_file(7) end, "(Harpoon)" }
mappings["7"] = { function() ui.nav_file(8) end, "(Harpoon)" }
mappings["8"] = { function() ui.nav_file(9) end, "(Harpoon)" }

register_normal(mappings)

-- Switch back from terminal
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>:e #<CR>")
