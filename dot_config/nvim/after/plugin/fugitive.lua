local whichkey = require "which-key"
local register_normal = require("od.which-key").register_normal

-- Tool up the fugitive buffers - props to [ThePrimeagen](https://github.com/ThePrimeagen/init.lua/blob/master/after/plugin/fugitive.lua)
local Od_Fugitive = vim.api.nvim_create_augroup("Od_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
    group = Od_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()

        local opts = {
            mode = "n",
            prefix = "<leader>",
            buffer = bufnr,
            silent = true,
            remap = false,
            nowait = false,
        }

        local mappings = {
            p = { function()
                vim.cmd.Git('push')
            end, "git push" },

            -- rebase always on pull
            P = {
                function()
                    vim.cmd.Git('pull --rebase')
                end, "git pull --rebase"
            },

            -- NOTE: It allows me to easily set the branch i am pushing and any tracking
            -- needed if i did not set the branch up correctly
            t = { ":Git push -u origin ", "git push -u origin " },
        }

        whichkey.register(mappings, opts)

    end,
})

-- Global mappings
local mappings = {
    g = {
        name = "Git",
        s = { "<cmd>Git<CR>", "Status" },
    },
}

register_normal(mappings)
