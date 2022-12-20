-- TODO which-key
local builtin = require('telescope.builtin')
-- find "files"
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
-- find "repo"
vim.keymap.set('n', '<leader>fr', builtin.git_files, {})
-- find "grep"
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
-- find "buffer"
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
-- find "help"
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
