print("well hello there")

vim.cmd "autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path \"%\""
