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

# Font

I like [FiraCode](https://github.com/tonsky/FiraCode), but for [powerlevel10k](https://github.com/romkatv/powerlevel10k#fonts) you'll probably want the [NerdFonts version](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode).

# TODO

## Quickcycle "modes"

I am loving `<C-g>`, `<C-c>` for quicklist cycling.  I'd like to use the same for `[d`, `]d`, `harpoon` prev/next etc.
So basically keep a `quickcycle_mode` global somewhere which provides variants for these keys, and show the mode in the `luabar`.
Could get fancy and have it refuse to enter a mode without context (e.g. if quickfix list is empty).  Or have it "notice"
when, say, the quickfix list gets new entries and auto-switch mode.

> Could prev/next the modes with `<leader>'`/`<leader>,`

## Tree Nav

I like what I've done with folding nav, use exactly the same in the tree

## Small Things to Try Out

+ [toggleterm](https://github.com/akinsho/toggleterm.nvim)
+ A markdown link snippet
+ [lspkind](https://github.com/onsails/lspkind.nvim)
+ [fzf](https://github.com/junegunn/fzf.vim) ?
+ Take away manual bits (e.g. [nix-darwin](https://github.com/LnL7/nix-darwin) away dependencies)
