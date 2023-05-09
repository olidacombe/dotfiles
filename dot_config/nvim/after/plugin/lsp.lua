local lsp = require('lsp-zero')
local telescope = require("telescope.builtin")

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
                globals = { 'vim', 'P', }
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
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

local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    if client.name == "eslint" then
        client.stop()
        return
    end

    -- Try to init the window bar context
    if client.server_capabilities.documentSymbolProvider then
        local navic = require "nvim-navic"
        navic.attach(client, bufnr)
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", telescope.lsp_references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, opts)

    local Od_Lsp = vim.api.nvim_create_augroup("Od_Lsp", {})

    local autocmd = vim.api.nvim_create_autocmd
    -- Format on save
    autocmd({ "BufWritePre" }, {
        group = Od_Lsp,
        pattern = "*",
        callback = function()
            vim.lsp.buf.format()
        end,
    })
end

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
        { name = 'emoji' }
    }
})
