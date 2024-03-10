local whichkey = require("which-key")
local register_normal = require("od.which-key").register_normal
local quickcycle = require("od.quickcycle")

local fugitive_quickcycle_mappings = quickcycle.new({
	{ "change", next = "normal ]/=", prev = "normal [/=" },
})

local fugitive_buffers = {}

-- Tool up the fugitive buffers - props to [ThePrimeagen](https://github.com/ThePrimeagen/init.lua/blob/master/after/plugin/fugitive.lua)
local Od_Fugitive = vim.api.nvim_create_augroup("Od_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufEnter", {
	group = Od_Fugitive,
	pattern = "*",
	callback = function()
		if vim.bo.ft ~= "fugitive" then
			return
		end

		local bufnr = vim.api.nvim_get_current_buf()

		if fugitive_buffers[bufnr] then
			return
		end
		fugitive_buffers[bufnr] = true
		quickcycle.push(fugitive_quickcycle_mappings)
	end,
})

autocmd("BufWinEnter", {
	group = Od_Fugitive,
	pattern = "*",
	callback = function()
		if vim.bo.ft ~= "fugitive" then
			return
		end

		local bufnr = vim.api.nvim_get_current_buf()

		local opts = {
			mode = "n",
			prefix = "<leader>",
			buffer = bufnr,
			silent = true,
			remap = false,
			nowait = false,
		}

		local mappings = {
			p = {
				function()
					vim.cmd.Git("push")
				end,
				"git push",
			},

			-- rebase always on pull
			P = {
				function()
					vim.cmd.Git("pull --rebase")
				end,
				"git pull --rebase",
			},

			-- NOTE: It allows me to easily set the branch i am pushing and any tracking
			-- needed if i did not set the branch up correctly
			t = { ":G push -u origin ", "git push -u origin " },
			u = { ":G reset @~<CR>", "_un_commit" },
		}
		mappings["@"] = {
			":G push -u origin @<CR>",
			"git push -u origin @",
		}

		whichkey.register(mappings, opts)
	end,
})

autocmd("BufLeave", {
	group = Od_Fugitive,
	pattern = "*",
	callback = function()
		if vim.bo.ft ~= "fugitive" then
			return
		end
		local bufnr = vim.api.nvim_get_current_buf()
		if not fugitive_buffers[bufnr] then
			return
		end
		fugitive_buffers[bufnr] = nil
		quickcycle.pop()
	end,
})

-- Global mappings
local mappings = {
	g = {
		name = "Git",
		s = { "<cmd>Git<CR>", "Status" },
	},
}

register_normal(mappings)
