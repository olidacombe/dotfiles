require("od")

vim.cmd "autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path \"%\""
