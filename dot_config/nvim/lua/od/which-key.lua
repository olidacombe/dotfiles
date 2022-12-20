whichkey = require "which-key"

local wk = {}

local base_opts = {
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false, -- use `nowait` when creating keymaps
}

function register(mappings, mode)
    local opts = base_opts
    opts.mode = mode
    whichkey.register(mappings, opts)
end

function wk.register_normal(mappings)
    register(mappings, "n")
end

function wk.register_visual(mappings)
    register(mappings, "n")
end

return wk
