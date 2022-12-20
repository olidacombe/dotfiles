local register_normal = require("od.which-key").register_normal
local builtin = require('telescope.builtin')

register_normal({
    f = {
        name = "Fuzzy Find",
        {
            f = { builtin.find_files, "Files" },
            r = { builtin.git_files, "Files<=Repo" },
            g = { builtin.live_grep, "Grep" },
            b = { builtin.buffers, "Buffer" },
            h = { builtin.help_tags, "Help" },
        }
    }
})
