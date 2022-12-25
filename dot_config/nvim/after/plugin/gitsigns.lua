local whichkey = require("which-key")

require('gitsigns').setup {
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, mappings)
            local opts = {
                buffer = bufnr,
                mode = mode,
                prefix = '<leader>',
                silent = true,
                noremap = true,
                nowait = false,
            }

            whichkey.register(mappings, opts)
        end

        -- Navigation
        vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true, buffer = bufnr })

        vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true, buffer = bufnr })

        -- Text object
        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select Git Hunk" })

        local mappings = {
            h = {
                s = { ":Gitsigns stage_hunk<CR>", "Stage Hunk" },
                r = { ":Gitsigns reset_hunk<CR>", "Reset Hunk" },
            }
        }
        map({ 'n', 'v' }, mappings)

        mappings = {
            h = {
                S = { gs.stage_buffer, "Stage Buffer" },
                u = { gs.undo_stage_hunk, "Unstage Hunk" },
                R = { gs.reset_buffer, "Reset Buffer" },
                p = { gs.preview_hunk, "Preview Hunk" },
                b = { function() gs.blame_line { full = true } end, "Blame Line" },
                d = { gs.diffthis, "Diff This" },
                D = { function() gs.diffthis('~') end, "Diff This~" },
            },
            t = {
                b = { gs.toggle_current_line_blame, "Toggle Blame" },
                d = { gs.toggle_deleted, "Toggle Deleted" },
            },
        }
        map('n', mappings)

    end
}
