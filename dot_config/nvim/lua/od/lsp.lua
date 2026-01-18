local M = {}

M.float_diagnostics = true

M.on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

    if client.name == "eslint" then
        client.stop()
        return
    end

    -- Try to init the window bar context
    if client.server_capabilities.documentSymbolProvider then
        local navic = require("nvim-navic")
        navic.attach(client, bufnr)
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = M.float_diagnostics }) end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = M.float_diagnostics }) end, opts)
    vim.keymap.set("n", "<leader>lr", ":lsp restart<cr>", opts)
    vim.keymap.set("n", "<leader>li", ":checkhealth vim.lsp<cr>", opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>vd", function()
        M.float_diagnostics = not M.float_diagnostics
    end, opts)
    vim.keymap.set("n", "<leader>vi", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, opts)
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

-- Tell the server the capability of foldingRange,
-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

return M
