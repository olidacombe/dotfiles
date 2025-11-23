-- require('copilot').setup({
--     -- suggestion = { enabled = false },  -- disable Copilot suggestions
--     -- panel = { enabled = false },  -- disable Copilot panel
-- })

vim.keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false
})
vim.g.copilot_no_tab_map = true
-- vim.keymap.set('i', '<C-g>', '<Plug>(copilot-previous)', {
--     expr = true,
--     noremap = false
-- })
-- vim.keymap.set('i', '<C-c>', '<Plug>(copilot-next)', {
--     expr = true,
--     noremap = false
-- })

vim.keymap.set("n", "<leader>c", "<Nop>", {
    desc = "Copilot"
})
vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>')
vim.keymap.set('n', '<leader>cd', ':Copilot disable<CR>')
