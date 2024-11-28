local lsp = require("lsp-zero")
local on_attach = require("od.lsp").on_attach

require("config.rustaceanvim")

require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        "eslint",
        "graphql",
        "pyright",
        "ruff",
        -- 'lua_ls', -- sadly broken or arm
        "svelte",
        "tailwindcss",
        "yamlls",
    },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({})
        end,
        lua_ls = function()
            -- local lua_opts = lsp.nvim_lua_ls()
            -- require("lspconfig").lua_ls.setup(lua_opts)
        end,
    },
})

-- FIXME, some deprecated stuff is in here
lsp.preset({
    float_border = 'rounded',
    call_servers = 'local',
    configure_diagnostics = true,
    setup_servers_on_start = true,
    set_lsp_keymaps = { omit = { '<C-k>' } },
    manage_nvim_cmp = {
        set_sources = 'recommended',
        set_basic_mappings = true,
        set_extra_mappings = false,
        use_luasnip = true,
        set_format = true,
        documentation_window = true,
    },
})

lsp.configure("pyright", {
    settings = {
        pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { "*" },
            },
        },
    },
})

-- lsp.configure("ruff_lsp", {
-- 	settings = {
-- 		init_options = {
-- 			settings = {
-- 				-- Any extra CLI arguments for `ruff` go here.
-- 				args = {},
-- 			},
-- 		},
-- 	},
-- })

-- Fix Undefined global 'vim'
lsp.configure("lua_ls", {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim", "P" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
        },
    },
})

lsp.configure("yamlls", {
    settings = {
        yaml = {
            schemaStore = {
                url = "https://www.schemastore.org/api/json/catalog.json",
                enable = true,
            },
            schemas = {
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0/all.json"] = "*.yaml",
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
                    "ci/*.yml",
                    ".gitlab-ci.yml",
                },
            },
        },
    },
})

lsp.configure("svelte", {
    settings = {
        svelte = {
            ["enable-ts-plugin"] = true,
        },
    },
})

lsp.on_attach(on_attach)

-- extend default capabilities with those required by ufo
local base_caps = require("cmp_nvim_lsp").default_capabilities()
local folding_caps = vim.lsp.protocol.make_client_capabilities()
folding_caps.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}
local capabilities = vim.tbl_deep_extend("force", base_caps, folding_caps)
lsp.set_server_config({
    capabilities = capabilities,
})

-- configure neodev before lsp
require("neodev").setup({
    library = { plugins = { "neotest" }, types = true },
})
lsp.setup()

local cmp = require("cmp")

cmp.setup({
    experimental = {
        -- allow autocomplete typeahead feel
        ghost_text = true,
        -- use next-gen menu
        native_menu = false,
    },
    mapping = {
        -- Stop enter from triggering things
        ["<CR>"] = function(fallback)
            cmp.mapping.close()
            fallback()
        end,
    },
    sources = {
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "buffer",  keyword_length = 3 },
        { name = "luasnip", keyword_length = 2 },
        { name = "crates" },
        { name = "emoji" },
    },
})
