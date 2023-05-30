local M = {}

local tpoon_file = os.getenv("HOME") .. "/.local/tpoon"
local selection = nil

local od_tpoon = vim.api.nvim_create_augroup("Od_tpoon", { clear = true })

local function save_and_close()
	vim.cmd("wq")
end

local function select_entry()
	selection = vim.api.nvim_win_get_cursor(0)[1]
	save_and_close()
end

M.open = function()
	selection = nil

	vim.cmd("e " .. tpoon_file)
	vim.api.nvim_buf_set_option(0, "filetype", "tpoon")
	vim.api.nvim_win_set_option(0, "number", true)

	vim.api.nvim_create_autocmd("BufWinLeave", {
		group = od_tpoon,
		callback = function()
			if selection then
				vim.cmd("silent!! tpoon " .. selection)
			end
		end,
		buffer = 0,
	})

	vim.keymap.set("n", "q", save_and_close, { silent = true, buffer = 0 })
	vim.keymap.set("n", "<cr>", select_entry, { silent = true, buffer = 0 })
end

vim.api.nvim_create_user_command("Tpoon", M.open, { desc = "Read output of `terraform plan` into buffer" })

return M
