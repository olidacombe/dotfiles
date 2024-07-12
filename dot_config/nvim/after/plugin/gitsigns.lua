local whichkey = require("which-key")

require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map(mappings)
			local opts = {
				buffer = bufnr,
				silent = true,
				noremap = true,
				nowait = false,
			}

			whichkey.add(mappings, opts)
		end

		-- Navigation
		vim.keymap.set("n", "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, buffer = bufnr })

		vim.keymap.set("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, buffer = bufnr })

		-- Text object
		vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Git Hunk" })

		local mappings = {
			{ "hs", ":Gitsigns stage_hunk<CR>", mode = { "n", "v" }, desc = "Stage Hunk" },
			{ "hr", ":Gitsigns reset_hunk<CR>", mode = { "n", "v" }, desc = "Reset Hunk" },
		}
		map(mappings)

		mappings = {
			{ "hS", gs.stage_buffer, desc = "Stage Buffer" },
			{ "hu", gs.undo_stage_hunk, desc = "Unstage Hunk" },
			{ "hR", gs.reset_buffer, desc = "Reset Buffer" },
			{ "hp", gs.preview_hunk, desc = "Preview Hunk" },
			{
				"hb",
				function()
					gs.blame_line({ full = true })
				end,
				desc = "Blame Line",
			},
			{ "hd", gs.diffthis, desc = "Diff This" },
			{
				"hD",
				function()
					gs.diffthis("~")
				end,
				desc = "Diff This~",
			},
			{ "tb", gs.toggle_current_line_blame, desc = "Toggle Blame" },
			{ "td", gs.toggle_deleted, desc = "Toggle Deleted" },
		}
		map(mappings)
	end,
})
