local register_normal = require("od.which-key").register_normal
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")
local telescope = require("telescope")

local normal_mappings = {
	f = {
		name = "Fuzzy Find",
		{
			C = { builtin.colorscheme, "Colourscheme" },
			F = {
				function()
					builtin.git_files({ hidden = true })
				end,
				"Files<=Repo",
			},
			f = {
				function()
					builtin.find_files({
						hidden = true,
					})
				end,
				"Files",
			},
			r = { builtin.registers, "Registers" },
			R = { builtin.resume, "Resume" },
			G = { builtin.live_grep, "Grep" },
			g = {
				function()
					builtin.grep_string({
						shorten_path = true,
						word_match = "-w",
						only_sort_text = true,
						search = "",
					})
				end,
				'"Rg - ish"',
			},
			k = { builtin.keymaps, "Keymaps" },
			b = { builtin.current_buffer_fuzzy_find, "Within buffer" },
			B = { builtin.buffers, "Buffers" },
			h = { builtin.help_tags, "Help" },
			m = { "<cmd>Telescope makemapper<cr>", "Make Targets" },
			s = { builtin.lsp_document_symbols, "Document Symbols" },
			S = { builtin.lsp_workspace_symbols, "Workspace Symbols" },
			q = { builtin.quickfix, "Quickfix" },
		},
	},
	g = {
		b = { builtin.git_branches, "Branch" },
		c = { builtin.git_commits, "Commits" },
	},
}

normal_mappings.f['"'] = { builtin.registers, "Registers" }

register_normal(normal_mappings)

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
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
	},
	pickers = {
		colorscheme = {
			enable_preview = true,
		},
	},
})

telescope.load_extension("fzf")
telescope.load_extension("harpoon")
telescope.load_extension("makemapper")
telescope.load_extension("monorepo")

-- temp fix for https://github.com/nvim-telescope/telescope.nvim/issues/2027
local od_i2027 = vim.api.nvim_create_augroup("Od_i2027", { clear = true })
vim.api.nvim_create_autocmd(
	-- Prevent entering buffers in insert mode.
	"WinLeave",
	{
		group = od_i2027,
		pattern = "*",
		callback = function()
			if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
			end
		end,
	}
)
