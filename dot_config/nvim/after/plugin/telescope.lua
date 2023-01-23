local register_normal = require("od.which-key").register_normal
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")
local telescope = require("telescope")

register_normal({
    d = {
        name = "Document",
        s = { builtin.lsp_document_symbols, "Symbols" },
    },
    f = {
        name = "Fuzzy Find",
        {
            C = { builtin.colorscheme, "Colourscheme" },
            f = { builtin.find_files, "Files" },
            r = { builtin.git_files, "Files<=Repo" },
            G = { builtin.live_grep, "Grep" },
            g = { function() builtin.grep_string({
                    shorten_path = true, word_match = "-w", only_sort_text = true, search = ''
                })
            end, '"Rg - ish"' },
            b = { builtin.current_buffer_fuzzy_find, "Within buffer" },
            B = { builtin.buffers, "Buffers" },
            h = { builtin.help_tags, "Help" },
            q = { builtin.quickfix, "Quickfix" },
        }
    },
    g = {
        b = { builtin.git_branches, "Branch" },
    },
    k = { builtin.keymaps, "Keymaps" },
    w = {
        name = "Workspace",
        s = { builtin.lsp_workspace_symbols, "Symbols" },
    },
})

local has_selections = function(prompt_bufnr)
    -- return true if any selections have been made
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selections = picker:get_multi_selection()
    return (#selections > 0)
end

local send_to_qflist = function(prompt_bufnr, mode, target)
    -- send selections or whole filtered list when none have been made
    if has_selections(prompt_bufnr) then
        return actions.send_selected_to_qflist(prompt_bufnr, mode, target)
    end
    return actions.send_to_qflist(prompt_bufnr, mode, target)
end

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<C-q>"] = send_to_qflist,
            },
            n = {
                ["<C-q>"] = send_to_qflist,
            },
        },
    },
    pickers = {
        colorscheme = {
            enable_preview = true
        }
    },
})

telescope.load_extension('harpoon')
