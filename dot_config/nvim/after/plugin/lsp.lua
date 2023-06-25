local lsp = require('lsp-zero')
local on_attach = require("od.lsp").on_attach

lsp.preset('recommended')
lsp.nvim_workspace()

lsp.setup_nvim_cmp({
    experimental = {
        -- allow autocomplete typeahead feel
        ghost_text = true,
        -- use next-gen menu
        native_menu = false,
    },
})

lsp.ensure_installed({
    'eslint',
    'graphql',
    'pyright',
    'rust_analyzer',
    -- 'lua_ls', -- sadly broken or arm
    'svelte',
    'tailwindcss',
    'tsserver',
    'yamlls',
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim', 'P', },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
            },
        },
    }
})

lsp.configure('yamlls', {
    settings = {
        yaml = {
            schemaStore = {
                url = "https://www.schemastore.org/api/json/catalog.json",
                enable = true,
            },
            schemas = {
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0/all.json"] = "*.yaml",
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
                    "ci/*.yml", ".gitlab-ci.yml" },
            },
        }
    }
})

lsp.configure('svelte', {
    settings = {
        svelte = {
            ['enable-ts-plugin'] = true
        }
    }
})

lsp.on_attach(on_attach)

-- extend default capabilities with those required by ufo
local base_caps = require('cmp_nvim_lsp').default_capabilities()
local folding_caps = vim.lsp.protocol.make_client_capabilities()
folding_caps.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}
local capabilities = vim.tbl_deep_extend('force', base_caps, folding_caps)
lsp.set_server_config({
    capabilities = capabilities
})

-- configure neodev before lsp
require("neodev").setup({
    library = { plugins = { "neotest" }, types = true },
})
lsp.setup()

local cmp = require('cmp')

cmp.setup({
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'buffer',  keyword_length = 3 },
        { name = 'luasnip', keyword_length = 2 },
        { name = 'crates' },
        { name = 'emoji' }
    }
})
