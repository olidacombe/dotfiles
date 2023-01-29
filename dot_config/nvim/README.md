# Notes

## Manual Install Steps

+ Install [packer.nvim](https://github.com/wbthomason/packer.nvim)

## Tips

Source current file:
```
:so
```

Sync plugins:
```
:PackerSync
```

See where mappings come from (all prefixed with `<leader>` in this example):
```
:verbose nmap <leader>
``

# Font

I like [FiraCode](https://github.com/tonsky/FiraCode), but for [powerlevel10k](https://github.com/romkatv/powerlevel10k#fonts) you'll probably want the [NerdFonts version](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode).


## TODO

+ Quickcycle mapping for `DiffviewFiles` (instead of `<(S)-Tab>`)
+ A mapping which take a line like `use('bla/whatever.nvim')` and takes you to the git repo in your browser


## Small Things to Try Out

+ [toggleterm](https://github.com/akinsho/toggleterm.nvim) or [bufterm.nvim](https://github.com/boltlessengineer/bufterm.nvim)
+ A markdown link snippet
+ [lspkind](https://github.com/onsails/lspkind.nvim)
+ [fzf](https://github.com/junegunn/fzf.vim) ?
+ Take away manual bits (e.g. [nix-darwin](https://github.com/LnL7/nix-darwin) away dependencies)
