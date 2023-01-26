require("od")

-- Automatically apply changes when editing chezmoi-controlled files
-- TODO remove hardcode of "~/.local/share/chezmoi/*"?
vim.cmd.autocmd("BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path \"%\" --force")
