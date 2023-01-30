local register_normal = require("od.which-key").register_normal
local actions = require("diffview.actions")
local quickcycle = require("od.quickcycle")

local quickcycle_mappings = quickcycle.new({
    { "change",
        next = "normal ]c", prev = "normal [c" },
    { "conflict",
        next = "normal ]x", prev = "normal [x" },
})

local file_panel_common_mappings = {
    { "n", "<C-g>", actions.select_prev_entry, { desc = "Next" } },
    { "n", "<C-c>", actions.select_next_entry, { desc = "Prev" } },
    ["<tab>"] = false,
    ["<s-tab>"] = false,
}

require("diffview").setup({
    view = {
        -- Configure the layout and behavior of different types of views.
        -- Available layouts:
        --  'diff1_plain'
        --    |'diff2_horizontal'
        --    |'diff2_vertical'
        --    |'diff3_horizontal'
        --    |'diff3_vertical'
        --    |'diff3_mixed'
        --    |'diff4_mixed'
        -- For more info, see ':h diffview-config-view.x.layout'.
        default = {
            -- Config for changed files, and staged files in diff views.
            layout = "diff2_horizontal",
        },
        merge_tool = {
            -- Config for conflicted files in diff views during a merge or rebase.
            layout = "diff3_mixed",
            disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
        },
        file_history = {
            -- Config for changed files in file history views.
            layout = "diff2_horizontal",
        },
    },
    hooks = {
        view_enter = function()
            quickcycle.push(quickcycle_mappings)
        end,
        view_leave = quickcycle.pop
    },
    keymaps = {
        file_panel = file_panel_common_mappings,
        file_history_panel = file_panel_common_mappings,
    },
})
-- try to get a nice fill and fail
-- vim.opt.fillchars:append('diff:╱')

-- Global mappings
local mappings = {
    g = {
        D = { "<cmd>DiffviewOpen<CR>", "Diff" },
        h = { "<cmd>DiffviewFileHistory %<CR>", "File History" },
    }
}

register_normal(mappings)
