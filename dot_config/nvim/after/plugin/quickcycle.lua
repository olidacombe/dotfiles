local quickcycle = require("od.quickcycle")

local od_qf = vim.api.nvim_create_augroup("Od_qf", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufEnter", {
    group = od_qf,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "qf" then return end
        quickcycle.try_select("qf")
    end
})
