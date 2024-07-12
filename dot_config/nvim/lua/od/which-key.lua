require("od.remap")
local whichkey = require("which-key")

local wk = {}

local function get_opts(mode)
	local opts = {
		mode = mode,
		buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
		silent = true, -- use `silent` when creating keymaps
		noremap = true, -- use `noremap` when creating keymaps
		nowait = false, -- use `nowait` when creating keymaps
	}
	return opts
end

local function register(mappings, mode, prefix)
	prefix = prefix or ""
	local opts = get_opts(mode)
	local prefixed_mappings = {}
	for _, v in ipairs(mappings) do
		v[1] = prefix .. v[1]
		table.insert(prefixed_mappings, v)
	end
	whichkey.add(prefixed_mappings, opts)
end

-- normal mappings - with leader
function wk.register_normal(mappings)
	register(mappings, "n", "<leader>")
end

-- visual mappings - no leader
function wk.register_visual(mappings)
	register(mappings, "v")
end

-- normal and visual mappings - with leader
function wk.register_nv(mappings)
	register(mappings, { "n", "v" }, "<leader>")
end

return wk
