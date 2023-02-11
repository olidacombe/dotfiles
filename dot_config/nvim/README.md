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
```

# Font

I like [FiraCode](https://github.com/tonsky/FiraCode), but for [powerlevel10k](https://github.com/romkatv/powerlevel10k#fonts) you'll probably want the [NerdFonts version](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode).


## TODO

+ Fix `q:` editing :thinking: - definitely looks `statuscolumn`-related
+ A "make mappings" plugin.  Basically if your `Makefile` implements a special (overridable) target like `__nvim_mappings`, then the plugin will call this target to get the necessary info to create mappings under a (overridable) prefix.
+ `n,v` mapping to execute line/selection, maybe in a floating term or whatever
+ A mapping which take a line like `use('bla/whatever.nvim')` and takes you to the git repo in your browser

### Make Mappings

E.g. if `make  __nmim_mappings` returns:

```json
{
    "b": "build",
    "c": "clean"
}
```

Then normal-mode mappings are created (assuming the default prefix for the plugin is `<leader>m`):

+ `<leader>mb` -> `:make build`
+ `<leader>mc` -> `:make clean`

And we could document some annotation mechanism for auto-populating this special target (like with self-documenting make targets)


## Small Things to Try Out

+ [vim-caser](https://github.com/arthurxavierx/vim-caser) instead of `vim-abolish` case changes. It can use visual mode for example.
+ [toggleterm](https://github.com/akinsho/toggleterm.nvim) or [bufterm.nvim](https://github.com/boltlessengineer/bufterm.nvim)
+ A markdown link snippet
+ [lspkind](https://github.com/onsails/lspkind.nvim)
+ [fzf](https://github.com/junegunn/fzf.vim) ?
+ Take away manual bits (e.g. [nix-darwin](https://github.com/LnL7/nix-darwin) away dependencies)
