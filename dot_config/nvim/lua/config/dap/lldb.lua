local dap = require("dap")
local os_cb = require("utils").os_cb

local M = {}

local lib_extension = "so"
os_cb({
	darwin = function()
		lib_extension = "dylib"
	end,
})

M.adapter_components = function()
	local mason_root_dir = require("mason.settings").current.install_root_dir
	return {
		exe = mason_root_dir .. "/packages/codelldb/extension/adapter/codelldb",
		lib = mason_root_dir .. "/packages/codelldb/extension/lldb/lib/liblldb." .. lib_extension,
	}
end

M.setup = function()
	local mason_root_dir = require("mason.settings").current.install_root_dir

	dap.adapters.lldb = {
		type = "server",
		port = "${port}",
		executable = {
			command = mason_root_dir .. "/bin/codelldb",
			args = { "--port", "${port}" },
		},
	}
end

return M
