vim.g.mapleader = " "

-- Slide visual selections around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Tab Nav
vim.keymap.set("n", "<Tab>", ":tabn<CR>")
vim.keymap.set("n", "<S-Tab>", ":tabp<CR>")

local os_cb = require('utils').os_cb
--  _______    _     _    _______
-- (_______)  | |   | |  (_______)
--  _____ ___ | | __| |   _     _ _____ _   _
-- |  ___) _ \| |/ _  |  | |   | (____ | | | |
-- | |  | |_| | ( (_| |  | |   | / ___ |\ V /
-- |_|   \___/ \_)____|  |_|   |_\_____| \_/
--
local get_current_line = function()
    return vim.api.nvim_win_get_cursor(0)[1]
end

local is_folded_at = function(line)
    return vim.fn.foldclosed(line) ~= -1
end

local next_closed_fold = function(jk)
    local current_line = get_current_line()
    repeat
        local last_line = current_line
        vim.cmd("normal z" .. jk)
        current_line = get_current_line()
        if is_folded_at(current_line) then
            return
        end
    until (current_line == last_line)
end

local up_fold = function()
    local line = get_current_line()
    vim.cmd("normal [z")
    if line == get_current_line() then
        vim.cmd("normal zk")
    end
end

local is_in_fold = function(line)
    return vim.fn.foldlevel(line) ~= 0
end

vim.keymap.set("n", "<Right>", function()
    if is_folded_at(get_current_line()) then
        return vim.cmd("normal zo")
    end
    next_closed_fold('j')
end)

vim.keymap.set("n", "<Left>", function()
    local l = get_current_line()
    if is_folded_at(l) then
        return up_fold()
    end
    if is_in_fold(l) then
        vim.cmd("normal zc")
    end
end)
vim.keymap.set("n", "<Up>", "zk")
vim.keymap.set("n", "<Down>", "zj")


--    ___       ___       ___       ___       ___
--   /\  \     /\__\     /\  \     /\  \     /\__\
--  /::\  \   /:/ _/_   _\:\  \   /::\  \   /:/ _/_
--  \:\:\__\ /:/_/\__\ /\/::\__\ /:/\:\__\ /::-"\__\
--   \::/  / \:\/:/  / \::/\/__/ \:\ \/__/ \;:;-",-"
--   /:/  /   \::/  /   \:\__\    \:\__\    |:|  |
--   \/__/     \/__/     \/__/     \/__/     \|__|
--    ___       ___       ___       ___       ___
--   /\  \     /\__\     /\  \     /\__\     /\  \
--  /::\  \   |::L__L   /::\  \   /:/  /    /::\  \
-- /:/\:\__\  |:::\__\ /:/\:\__\ /:/__/    /::\:\__\
-- \:\ \/__/  /:;;/__/ \:\ \/__/ \:\  \    \:\:\/  /
--  \:\__\    \/__/     \:\__\    \:\__\    \:\/  /
--   \/__/               \/__/     \/__/     \/__/
--    ___       ___       ___
--   /\__\     /\  \     /\__\
--  /:| _|_   /::\  \   /:/ _/_
-- /::|/\__\ /::\:\__\ |::L/\__\
-- \/|::/  / \/\::/  / |::::/  /
--   |:/  /    /:/  /   L;;/__/
--   \/__/     \/__/
--
local quickcycle = require("od.quickcycle")

os_cb({
    linux = function()
        vim.keymap.set("n", "<A-g>", quickcycle.mode_prev)
        vim.keymap.set("n", "<A-c>", quickcycle.mode_next)
    end,
    darwin = function()
        vim.keymap.set("n", "©", quickcycle.mode_prev)
        vim.keymap.set("n", "ç", quickcycle.mode_next)
    end,
})
vim.keymap.set("n", "<C-g>", quickcycle.prev)
vim.keymap.set("n", '<C-c>', quickcycle.next)

-- Edit dir of current file
vim.keymap.set("n", "-", function()
    local buf = require("od.buffer").current_path()
    if buf == "" then buf = vim.fn.getcwd() .. "/" end
    local dir = buf:gsub("/[^/]*$", "")
    vim.cmd("e " .. dir)
end, { desc = "Edit current dir" })

-- All else has moved to `which-key.lua`
