#!/usr/bin/env bash

# Rebuild mise's shim farm after chezmoi has written ~/.config/mise.
#
# Why this exists: a `lazy = true` tool only gets its bootstrap shim (the stub
# that installs the real thing on first use) when the farm is reconciled. A
# hand-written or freshly-rendered config has no shims until something runs
# `mise reshim`, and the gap is invisible in an interactive shell — mise
# activate's command-not-found handler installs the tool anyway — while a task,
# `mise exec` child, or a program that reads no shell rc file at all just fails
# with "command not found". See https://github.com/jdx/mise/pull/12687.
#
# Runs on every `chezmoi apply` because it is ~70ms, and because the generated
# conf.d fragments are rendered by chezmoi (so hashing them here would need the
# same template logic twice).

set -uo pipefail

if ! command -v mise >/dev/null 2>&1; then
    echo "mise not on PATH yet (bootstrap installs it) — skipping reshim"
    exit 0
fi

# Lazy tool shims need mise >= 2026.9.0. `mise --version` prints e.g.
# "2026.11.3 linux-x64 (2026-11-07)". Compared with shell arithmetic on purpose:
# an awk numeric-vs-strnum compare falls back to string order, so "unknown" would
# have counted as newer than "2026".
version=$(mise --version 2>/dev/null | awk '{ print $1 }')
year=${version%%.*}
rest=${version#*.}
month=${rest%%.*}
case "${year}${month}" in
    '' | *[!0-9]*) echo "cannot read mise version (${version:-missing}) — skipping reshim"; exit 0 ;;
esac
if [ "$year" -lt 2026 ] || { [ "$year" -eq 2026 ] && [ "$month" -lt 9 ]; }; then
    echo "mise $version predates lazy tool shims (needs >= 2026.9.0)"
    echo "  run: mise self-update   (or \`mise install --include-lazy\` to skip lazy entirely)"
    exit 0
fi

mise reshim || echo "mise reshim failed — run it by hand"
