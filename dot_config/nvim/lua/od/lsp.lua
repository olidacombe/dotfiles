local M = {}

M.on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

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
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>lr", ":LspRestart<cr>", opts)
    vim.keymap.set("n", "<leader>li", ":LspInfo<cr>", opts)
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

return M
