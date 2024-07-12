local whichkey = require("which-key")
local register_normal = require("od.which-key").register_normal
local quickcycle = require("od.quickcycle")

local fugitive_quickcycle_mappings = quickcycle.new({
    { "change", next = "normal ]/=", prev = "normal [/=" },
})

local fugitive_buffers = {}

-- Tool up the fugitive buffers - props to [ThePrimeagen](https://github.com/ThePrimeagen/init.lua/blob/master/after/plugin/fugitive.lua)
local Od_Fugitive = vim.api.nvim_create_augroup("Od_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufEnter", {
    group = Od_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()

        if fugitive_buffers[bufnr] then
            return
        end
        fugitive_buffers[bufnr] = true
        quickcycle.push(fugitive_quickcycle_mappings)
    end,
})

autocmd("BufWinEnter", {
    group = Od_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()

        local opts = {
            buffer = bufnr,
            silent = true,
            remap = false,
            nowait = false,
        }

        local mappings = {
            {
                "<leader>p",
                function()
                    vim.cmd.Git("push")
                end,
                desc = "git push",
            },

            -- rebase always on pull
            {
                "<leader>P",
                function()
                    vim.cmd.Git("pull --rebase")
                end,
                desc = "git pull --rebase",
            },

            -- NOTE: It allows me to easily set the branch i am pushing and any tracking
            -- needed if i did not set the branch up correctly
            { "<leader>t", ":G push -u origin ",      desc = "git push -u origin " },
            { "<leader>u", ":G reset @~<CR>",         desc = "_un_commit" },
            { "<leader>@", ":G push -u origin @<CR>", desc = "git push -u origin @" },
        }

        whichkey.add(mappings, opts)
    end,
})

autocmd("BufLeave", {
    group = Od_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end
        local bufnr = vim.api.nvim_get_current_buf()
        if not fugitive_buffers[bufnr] then
            return
        end
        fugitive_buffers[bufnr] = nil
        quickcycle.pop()
    end,
})

-- Global mappings
local mappings = {
    { "gs", "<cmd>Git<CR>", desc = "Status" },
}

register_normal(mappings)
