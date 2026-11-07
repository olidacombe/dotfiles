# lazy-mise

I use this repo to standardise a portable setup between machines, and
`bootstrap.sh` to get a new one set up. Per package manager I kept a minimal list
(`*-core`) and a full-fat list (`*-full`):

    pacfile-core / pacfile-full          pacman
    yayfile-core / yayfile-full          yay (AUR)
    aptfile-core / aptfile-full          apt
    crates-core.txt / crates-full.txt    cargo install
    npm_globals                          npm i -g
    Brewfile                             brew bundle

Then I started using mise, and wanted to port as much as possible to it — but
bootstrap is slow, because everything installs up front whether or not I ever run
it. Hence **lazy-mise**: keep the lists as the source of truth, and let mise
install the rarely-used part on first use.

## What mise already gives you

Lazy tool shims shipped in **mise v2026.9.0** (PR jdx/mise#12594), so there is
nothing to script — declare a tool lazy and mise publishes only a bootstrap shim:

```toml
[tools]
ripgrep = { version = "latest", lazy = true }                       # registry: knows the bins
"cargo:speedtest-tui" = { version = "latest", lazy = true, lazy_bins = ["speedtest-tui"] }
```

Verified behaviour on 2026.11.3 (this repo's rendered config, throwaway
`MISE_CONFIG_DIR`/`MISE_DATA_DIR`):

| Command / event | Result |
| --- | --- |
| `mise install` (no args) | installs everything **except** lazy tools |
| `mise install --include-lazy` | installs the lazy ones too |
| `mise ls` | shows `btop 1.4.8 (lazy)` — not reported as missing |
| first `btop` on `PATH` | installs btop, then runs it (`mise ✓ btop@1.4.8  …`) |
| every later `btop` | runs the real binary, no mise dispatch |
| `mise bootstrap status` | lists the `[bootstrap.packages]` entries, skipping managers this machine lacks |

Two gotchas that shaped the layout:

* **`lazy_bins` is required for non-registry backends.** Only registry tools carry
  `bins` metadata; `cargo:`/`npm:`/`pypi:`/`ubi:` entries without it are skipped
  with `Skipping invalid lazy shim declaration: … set lazy_bins explicitly`.
* **A hand-written lazy entry has no shim until the farm is rebuilt.** An
  interactive shell hides this (mise activate's not-found handler installs the
  tool) but a task, `mise x` child, or an editor that reads no rc file just gets
  "command not found" (jdx/mise#12687). So `mise reshim` after every apply →
  `run_after_mise_reshim.sh`.
* **`depends` is an ordering requirement, not an auto-install.** Invoking a lazy
  tool whose declared dependency is not installed fails
  (`failed to resolve configured install dependency 'rust@stable' for …`). Hence
  node/rust/python are declared eagerly in `config.toml`.
* **`latest` needs network to resolve.** With `lockfile = false` mise resolves each
  request live and caches it, so `mise ls` on a flaky network prints
  `Failed to resolve tool version list for cargo:…` (crates.io in particular is
  slow here). Harmless — it retries — but it is another reason to warm the lazy set
  (`mise run warm-tools`) on a machine you want predictable.

## Layout

```
dot_config/mise/
├── config.toml                  hand-maintained: runtimes, settings, tasks
└── conf.d/
    ├── 10-core.toml.tmpl        GENERATED eager tools   (small, `mise install`)
    ├── 20-packages.toml.tmpl    GENERATED host packages (`mise bootstrap`)
    └── 50-lazy.toml.tmpl        GENERATED lazy tools    (first use)

.chezmoitemplates/mise/
├── mise-tools    the one routing list: what mise installs vs. the package manager
├── eager-tools   names that must never be lazy (shell/tmux/nvim startup)
├── declared      names config.toml owns by hand (fragments skip them)
├── bins          <crate-or-package>=<exe>,<exe>  → lazy_bins
├── routes        <name>=<mise key>               → renames / backend overrides
├── entry         normalise one list-file line to a package name
├── names         ported / native / eager / all / declared name sets
├── tools         render `[tools]` entries
└── packages      render `[bootstrap.packages]` entries
```

Name your fragments without dots (`50-lazy.toml`, never `50-lazy.nvidia.toml`):
from mise 2026.8.9 the filename component before `.toml` is read as an `MISE_ENV`
selector, so a dotted fragment silently stops loading.

The core/full split maps onto eager/lazy: `*-core` + startup-critical names from
`*-full` go to `10-core.toml`, the rest of `*-full` goes to `50-lazy.toml`, and
anything mise cannot install goes to `20-packages.toml` for `mise bootstrap`.
Files merge per tool rather than wholesale, and `config.toml` overrides the
fragments — so a machine that wants one thing eager (or another version) just
re-declares it there or in unmanaged `config.local.toml`.

## Template plumbing worth knowing

Getting chezmoi to do this had three traps, all recorded here so the next
template does not rediscover them:

* **`include` returns text and takes one argument.** A `{{ define }}` block in an
  included template is *not* visible to the caller, and `{{ include "x" . }}` is
  a parse error. Shared helpers therefore return strings, and are called with
  Go's `includeTemplate "mise/names" (dict …)` — `{{ $x := template … }}` is a
  parse error, so `includeTemplate` is the only way to bind a helper's output to
  a variable.
* **chezmoi parses `.chezmoitemplates/**` recursively**, so the short name
  `mise/names` resolves without hard-coding `.chezmoi.sourceDir` in every call, and
  `include` inside a helper resolves relative to the source dir. That matters here
  because a full source scan of this repo hits a dangling symlink in the
  `archinstall/` checkout and dies — one bad file makes every `chezmoi
  execute-template` fail, even for an unrelated template.
* **Optional arguments must be read as `index . "key"`.** Go errors on a missing
  map key, so `default "" .skip` aborts before the default applies. And helpers
  are only ever called with a `dict`, never the caller's `.chezmoi` struct (that
  has no `mode`/`files` fields — it would render an empty file instead of failing).

Rendered output is verified with a scratch destination, so nothing on this
machine is touched:

```sh
mkdir -p /tmp/final/conf/conf.d
HOME=/tmp/fh chezmoi cat --source="$PWD" /tmp/fh/.config/mise/config.toml > /tmp/final/conf/config.toml
for f in 10-core 20-packages 50-lazy; do
  HOME=/tmp/fh chezmoi cat --source="$PWD" "/tmp/fh/.config/mise/conf.d/$f.toml" > "/tmp/final/conf/conf.d/$f.toml"
done
cd /tmp/final && export MISE_CONFIG_DIR=$PWD/conf MISE_DATA_DIR=$PWD/data MISE_CACHE_DIR=$PWD/cache
mise ls && mise reshim && mise install --dry-run   # expect no WARN lines
```

## Notes / follow-ups

* mise itself cannot be lazy — it is what installs the rest. Bootstrap installs it
  (`ensure_mise`) and asserts ≥ 2026.9.0, `mise self-update` if not.
* **fzf and direnv are now installed by mise.** The oh-my-zsh plugins and
  `~/.fzf.zsh` run at startup, so both are eagerly declared; worth a look on a
  fresh machine that `dot_fzf.zsh`'s Linux branch still finds them.
* The `cargo:` backend resolves through cargo-binstall and only compiles when no
  prebuilt binary exists — that is why `stylua`, `cargo-make`, `cargo-binstall`
  and `cargo-insta` are routed to their registry entries in `routes`.
* `git-delta`/`du-dust` are deliberately registered as `cargo:git-delta`/
  `cargo:du-dust` with `lazy_bins = ["delta"]`/`["dust"]` rather than as the
  registry's `delta`/`dust`, so the crate list keeps being the source of truth;
  mise/tools de-duplicates by command name, so a shim can never be fought over.
* Bootstrap.sh keeps driving pacman/yay/apt/brew. `MISE_PACKAGES=1` swaps that for
  `mise run bootstrap-packages`; it is opt-in because `bootstrap packages apply`
  is destructive as a command class (it removes `state = "absent"` entries).
* A name can only be ported once. `mise-tools` is matched on the unqualified name,
  so `gh` (Brewfile) and `github-cli` (pacfile) both need a line, or the second
  spelling falls through to `[bootstrap.packages]` and you get gh from mise *and*
  brew. `mise bootstrap status` plus a tool/package name-intersection check is how
  the current set was audited — worth re-running after editing `mise-tools`.
* Not yet ported and probably should not be: the GUI/AUR builds, fonts, services,
  ghcup, and the zmk/ESP toolchains.
* Consider `mise.lock` (`mise lock`) if reproducibility between machines starts to
  matter more than `latest` everywhere.
* Applying this config does not uninstall anything. Tools already installed by
  `mise use` from a project config (here: pandoc, tinytex, watchexec, hx, lua,
  conda:perl, http:lilypond, npm:surge) stay installed and keep showing in
  `mise ls` with no config file next to them; `mise install` never prunes. The
  generated `config.toml` is a superset of the previous hand-written global one
  (node, cargo:speedtest-tui, npm:cline, micromamba are all carried over).
