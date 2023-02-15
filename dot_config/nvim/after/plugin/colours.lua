local Od_ColourScheme = vim.api.nvim_create_augroup("Od_ColourScheme", {})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = Od_ColourScheme,
    pattern = "*",
    callback = function()
        local colourscheme = vim.fn.expand("<amatch>")
        if colourscheme == "gruvbox" then return end
        vim.api.nvim_set_hl(0, "Normal", { bg = "none", })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end
})
