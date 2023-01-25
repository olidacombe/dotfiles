require("rose-pine").setup({
    -- covered globally below
    -- disable_background = true,
    -- disable_float_background = true,
})

function SetColourScheme(colour)
    colour = colour or "kanagawa"
    vim.cmd.colorscheme(colour)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

SetColourScheme()
