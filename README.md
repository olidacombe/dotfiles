# Quickstart

```zsh
sh -c "$(curl -fsLS https://github.com/olidacombe/dotfiles/raw/main/bootstrap.sh)"
```

## lazy-mise

Dev tools are managed by [mise](https://mise.jdx.dev), declared in
`~/.config/mise` by chezmoi from the `pacfile-*`, `aptfile-*`, `yayfile-*`,
`crates-*.txt`, `npm_globals` and `Brewfile` lists. `mise install` fetches only
the eager core set; the rest of the `*-full` lists are marked `lazy = true` and
install themselves the first time you run them (mise ≥ 2026.9.0 publishes a
bootstrap shim for each). Design notes and the routing lists live in
[`MISE.md`](MISE.md).

```zsh
mise install                    # eager core only
mise install --include-lazy     # or: mise run warm-tools (& disown)
mise ls                         # (lazy) = installs on first use, (missing) = not installed
mise reshim                     # after editing the generated conf.d fragments
mise bootstrap status           # host packages from [bootstrap.packages]
USE_MISE=0 ./bootstrap.sh       # pre-mise rustup/cargo-binstall/npm -g path
MISE_PACKAGES=1 ./bootstrap.sh  # let `mise run bootstrap-packages` do the packages
```

## TODO

+ [direnv -> mise](https://mise.jdx.dev/direnv.html) — mise now installs direnv and node/python/rust, so the `[direnv]` hook in mise can replace the oh-my-zsh direnv plugin + `~/.config/zsh/directories`
+ Brewfile - auto-check for dead formulae
+ port the remaining `*-full` names worth putting in mise (`.chezmoitemplates/mise/mise-tools`)
+ [cmd-enter](https://github.com/openai/codex/discussions/3024#discussioncomment-15002195) send newline (for codex cli)
+ [Pandoc-Emojis-Filter?](https://github.com/masbicudo/Pandoc-Emojis-Filter)
+ [quarto](https://quarto.org/)
+ a `<leader>r` to run a script within markdown bash code block
+ [tinymist](https://github.com/Myriad-Dreamin/tinymist)
+ migrate from simrat/rust-tools to [rustaceanvim](https://github.com/mrcjkb/rustaceanvim)
+ nested tmux
    - [clipboard](https://stackoverflow.com/questions/60923257/tmux-how-to-copy-text-between-nested-remote-ssh-session-and-local-machine)
    - pass-through things like new tab shortcut, and tab change
+ a branch name maker from arbitrary message (satisfy [this](https://git-scm.com/docs/git-check-ref-format))
+ `titgrep` - grep but keep first (title) line
    - `bodgrep` - grep but unconditionally skip first line
+ sort out meta key in linux so I can have an easy life with shortcuts between OSs
+ live fzf through git repos in my orgs or global with enough of a prompt - pipe to (gitget && tmux-sessionizer)
+ `sessionizer`-style live search of git repos to auto clone and sessionize
+ https://rycee.gitlab.io/home-manager/
+ https://github.com/tmux-plugins/tmux-resurrect
+ or https://github.com/tmux-plugins/tmux-continuum
+ sort out [pam-gnupg](https://github.com/cruegge/pam-gnupg)
