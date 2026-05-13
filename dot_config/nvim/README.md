# Notes

## Tips

See where mappings come from (all prefixed with `<leader>` in this example):
```
:verbose nmap <leader>
```

## Slack Links

The Markdown `gs` mapping opens the first Slack archive link on the current line in
the Slack desktop app. Workspace team IDs are private/local config and should not
be committed here.

Populate `${XDG_CONFIG_HOME:-~/.config}/slack/config.toml`:

```toml
[team_ids]
example-workspace = "T12345678"
```

Use the workspace subdomain from `https://example-workspace.slack.com/...` as the
key.

To find the team ID, open the workspace in Slack's web app. Slack documents the
loaded URL format as `https://app.slack.com/client/TXXXXXXX/CXXXXXXX`; the
workspace ID is the string beginning with `T`.

If you already have a Slack token for the workspace, Slack's `auth.test` API also
returns `team_id`:

```sh
curl -sS -H "Authorization: Bearer $SLACK_TOKEN" https://slack.com/api/auth.test | jq -r '.team_id'
```

References:

+ [Locate your Slack URL or ID](https://slack.com/help/articles/221769328-Locate-your-Slack-URL-or-ID)
+ [`auth.test` method](https://docs.slack.dev/reference/methods/auth.test/)

# Font

I like [FiraCode](https://github.com/tonsky/FiraCode), but for [powerlevel10k](https://github.com/romkatv/powerlevel10k#fonts) you'll probably want the [NerdFonts version](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode).


## TODO

+ finish terrabastard plugin 🌟
+ make a teleport for choosing a branch, and cracking open `:DiffviewOpen {branch}`
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
