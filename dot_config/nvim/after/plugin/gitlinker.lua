require "gitlinker".setup()

vim.api.nvim_set_keymap('n', '<leader>gw',
    '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
    { silent = true, desc = "web" })
vim.api.nvim_set_keymap('v', '<leader>gw',
    '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
    { silent = true, desc = "web" })
vim.api.nvim_set_keymap('n', '<leader>gY', '<cmd>lua require"gitlinker".get_repo_url()<cr>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>gW',
    '<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>',
    { silent = true, desc = "repo web" })
