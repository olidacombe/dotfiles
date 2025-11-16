local on_attach = require("od.lsp").on_attach
local capabilities = require("od.lsp").capabilities

require("config.rustaceanvim")

require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        "eslint",
        "graphql",
        "pyright",
        "ruff",
        'lua_ls', -- sadly broken or arm
        "svelte",
        "tailwindcss",
        "yamlls",
    },
})

-- FIXME, some deprecated stuff is in here
-- lsp.preset({
--     float_border = 'rounded',
--     call_servers = 'local',
--     configure_diagnostics = true,
--     setup_servers_on_start = true,
--     set_lsp_keymaps = { omit = { '<C-k>' } },
--     manage_nvim_cmp = {
--         set_sources = 'recommended',
--         set_basic_mappings = true,
--         set_extra_mappings = false,
--         use_luasnip = true,
--         set_format = true,
--         documentation_window = true,
--     },
-- })

vim.lsp.config("pyright", {
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
vim.lsp.enable("pyright")

-- Fix Undefined global 'vim'
vim.lsp.config("lua_ls", {
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
vim.lsp.enable("lua_ls")

vim.lsp.config("yamlls", {
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
vim.lsp.enable("yamlls")

vim.lsp.config("svelte", {
    settings = {
        svelte = {
            ["enable-ts-plugin"] = true,
        },
    },
})
vim.lsp.enable("svelte")

vim.lsp.config("*", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- configure neodev before lsp
require("neodev").setup({
    library = { plugins = { "neotest" }, types = true },
})

local cmp = require("cmp")

cmp.setup({
    experimental = {
        -- allow autocomplete typeahead feel
        ghost_text = true,
        -- use next-gen menu
        native_menu = false,
    },
    mapping = cmp.mapping.preset.insert({
        -- Stop overriding my beautifil luasnip "next"
        ["<C-N>"] = cmp.config.disable,
        -- Stop enter from triggering things
        ["<CR>"] = cmp.config.disable,
    }),
    sources = {
        { name = "copilot", group_index = 2 },
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "buffer",  keyword_length = 3 },
        { name = "luasnip", keyword_length = 2 },
        { name = "crates" },
        { name = "emoji" },
    },
})
