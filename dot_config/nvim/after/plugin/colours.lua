local Od_ColourScheme = vim.api.nvim_create_augroup("Od_ColourScheme", {})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = Od_ColourScheme,
    pattern = "*",
    callback = function()
        local colourscheme = vim.fn.expand("<amatch>")
        if colourscheme == "gruvbox" then return end
        require("od.colours").overrides()
    end
})
