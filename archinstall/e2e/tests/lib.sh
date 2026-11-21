# shellcheck shell=bash
# Minimal assertion helpers. Concatenated in front of a test file and piped to
# `bash -s` on the guest, so this must be self-contained.

_PASS=0 _FAIL=0 _WARN=0 _N=0
_FAILED=()

_run() {  # run "$@" capturing output; sets _OUT and returns its status
    _OUT=$("$@" 2>&1)
}

_report() {  # level desc status
    local level=$1 desc=$2 rc=$3
    _N=$((_N + 1))
    if [ "$rc" -eq 0 ]; then
        _PASS=$((_PASS + 1)); printf 'ok %d - %s\n' "$_N" "$desc"
    elif [ "$level" = warn ]; then
        _WARN=$((_WARN + 1)); printf 'ok %d - %s # WARN\n' "$_N" "$desc"
        [ -n "$_OUT" ] && printf '%s\n' "$_OUT" | tail -n 15 | sed 's/^/#   /'
    else
        _FAIL=$((_FAIL + 1)); _FAILED+=("$desc"); printf 'not ok %d - %s\n' "$_N" "$desc"
        [ -n "$_OUT" ] && printf '%s\n' "$_OUT" | tail -n 15 | sed 's/^/#   /'
    fi
    return 0
}

# check <description> <command...>   : command must succeed
check()      { local d=$1; shift; _run "$@"; _report fail "$d" $?; }
# warn <description> <command...>    : reported, but doesn't fail the stage
warn()       { local d=$1; shift; _run "$@"; _report warn "$d" $?; }
# check_eq <description> <expected> <command...> : trimmed stdout must equal expected
check_eq() {
    local d=$1 want=$2; shift 2
    _run "$@"; local rc=$?
    if [ $rc -eq 0 ] && [ "$_OUT" = "$want" ]; then _report fail "$d" 0
    else _OUT="expected: '$want'"$'\n'"got (rc=$rc): '$_OUT'"; _report fail "$d" 1; fi
}

section() { printf '# --- %s ---\n' "$*"; }

has_pkg() {  # accepts repo/name as used in yayfiles
    local p=${1##*/}
    pacman -Qq "$p" >/dev/null 2>&1 || pacman -Qqg "$p" >/dev/null 2>&1
}
unit_enabled() { systemctl is-enabled -q "$1"; }
unit_active()  { systemctl is-active -q "$1"; }
as_root()      { printf '%s\n' "$E2E_PASSWORD" | sudo -S -p '' "$@"; }

# Every package named in a pacfile-style list (comments stripped) is installed.
all_pkgs_from() {
    local f=$1 p missing=()
    [ -f "$f" ] || { echo "no such file: $f"; return 1; }
    for p in $(sed -e 's/#.*//' "$f" | awk NF); do has_pkg "$p" || missing+=("$p"); done
    [ ${#missing[@]} -eq 0 ] || { echo "missing: ${missing[*]}"; return 1; }
}

# Show output on success too (for diagnostics), but never fail
info() { local d=$1; shift; _run "$@"; printf '# %s:\n' "$d"; printf '%s\n' "$_OUT" | head -n 40 | sed 's/^/#   /'; }

finish() {
    printf '1..%d\n' "$_N"
    printf '# pass=%d fail=%d warn=%d\n' "$_PASS" "$_FAIL" "$_WARN"
    if [ "$_FAIL" -gt 0 ]; then
        printf '# FAILED: %s\n' "${_FAILED[@]}"
        exit 1
    fi
    exit 0
}
