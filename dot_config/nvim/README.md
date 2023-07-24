# Notes

## Tips

See where mappings come from (all prefixed with `<leader>` in this example):
```
:verbose nmap <leader>
```

# Font

I like [FiraCode](https://github.com/tonsky/FiraCode), but for [powerlevel10k](https://github.com/romkatv/powerlevel10k#fonts) you'll probably want the [NerdFonts version](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode).


## TODO

+ fix oil keymap clashes with c-{h,j,k,l}
+ async git
+ luasnips for work (jira prefix from branch name or similar)
+ quicx surround keymaps for common things
+ monorepo project sticky to tab?
+ open monorepo project root when changing project?
+ show monorepo project in lualine
+ `n,v` mapping to execute line/selection, maybe in a floating term or whatever
+ A mapping which take a line like `use('bla/whatever.nvim')` and takes you to the git repo in your browser


## Small Things to Try Out

+ [vim-caser](https://github.com/arthurxavierx/vim-caser) instead of `vim-abolish` case changes. It can use visual mode for example.
+ [toggleterm](https://github.com/akinsho/toggleterm.nvim) or [bufterm.nvim](https://github.com/boltlessengineer/bufterm.nvim)
+ A markdown link snippet
+ [lspkind](https://github.com/onsails/lspkind.nvim)
+ [fzf](https://github.com/junegunn/fzf.vim) ?
+ Take away manual bits (e.g. [nix-darwin](https://github.com/LnL7/nix-darwin) away dependencies)
