-- disable netrw at the very start of your init.lua
-- see https://github.com/nvim-tree/nvim-tree.lua#setup
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.statuscolumn = '%=%{v:lnum == line(".") ? v:lnum : v:relnum}%s%#FoldColumn#%{foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? " " : " ") : "  " }%*'

-- wait 300ms for a mapped sequence to complete
vim.opt.tm = 300

-- never let the cursor be less than 8 lines from the bottom
-- unless you're at the end of the file
vim.opt.scrolloff = 8

vim.opt.colorcolumn = nil
