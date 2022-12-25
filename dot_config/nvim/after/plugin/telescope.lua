local register_normal = require("od.which-key").register_normal
local telescope = require("telescope")
local builtin = require("telescope.builtin")

register_normal({
    f = {
        name = "Fuzzy Find",
        {
            f = { builtin.find_files, "Files" },
            r = { builtin.git_files, "Files<=Repo" },
            G = { builtin.live_grep, "Grep" },
            g = { function() builtin.grep_string({
                    shorten_path = true, word_match = "-w", only_sort_text = true, search = ''
                })
            end, '"Rg - ish"' },
            b = { builtin.buffers, "Buffer" },
            h = { builtin.help_tags, "Help" },
        }
    }
})

telescope.load_extension('harpoon')
