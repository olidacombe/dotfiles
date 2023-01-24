local register_normal = require("od.which-key").register_normal
local actions = require("diffview.actions")
local quickcycle = require("od.quickcycle")

local quickcycle_mappings = quickcycle.new({
    { "conflict",
        next = "normal ]x", prev = "normal [x" },
})

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
        keymaps = {
            { "n", "<C-g>", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
            { "n", "<C-c>", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
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
})
-- try to get a nice fill and fail
-- vim.opt.fillchars:append('diff:╱')

-- Global mappings
local mappings = {
    g = {
        D = { "<cmd>DiffviewOpen<CR>", "Diff" },
    }
}

register_normal(mappings)
