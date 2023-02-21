local M = {}

M.overrides = function()
    vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none", })
    vim.api.nvim_set_hl(0, "Normal", { bg = "none", })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return M
