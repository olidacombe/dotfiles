local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
local os_cb = require("utils").os_cb

local register_normal = require("od.which-key").register_normal

local mappings = {
    a = { mark.add_file, "Harpoon Mark" },
    e = { ui.toggle_quick_menu, "Harpoon List" },
    E = { ":Telescope harpoon marks<CR>", "Harpoon Telescope" },
    -- X = { function()
    --     vim.ui.input({
    --         prompt = "Command: ",
    --     }, function(input)
    --         if input then
    --             vim.api.nvim_command(":X " .. input)
    --         else
    --             print "Command cancelled"
    --         end
    --     end)
    -- end, "Execute in Terminal" },
}

register_normal(mappings)

-- easy quick-switches :D
os_cb({
    linux = function()
        vim.keymap.set("n", "<A-a>", function() ui.nav_file(1) end)
        vim.keymap.set("n", "<A-o>", function() ui.nav_file(2) end)
        vim.keymap.set("n", "<A-e>", function() ui.nav_file(3) end)
        vim.keymap.set("n", "<A-u>", function() ui.nav_file(4) end)
    end,
    darwin = function()
        vim.keymap.set("n", "æ", function() ui.nav_file(1) end)
        vim.keymap.set("n", "≤", function() ui.nav_file(2) end)
        vim.keymap.set("n", "≥", function() ui.nav_file(3) end)
        vim.keymap.set("n", "π", function() ui.nav_file(4) end)
    end,
})


-- Switch back from terminal
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>:e #<CR>")
