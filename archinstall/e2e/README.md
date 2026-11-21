# archinstall e2e

Unattended test of the ISO from `../Makefile`: install → boot → test → `bootstrap.sh` → reboot → test → log in graphically.

```
make e2e              # everything (uses latest ISO; builds one if missing)
make e2e-build        # non-interactive ISO build (sudo for mkarchiso; placeholder password, don't burn)
make e2e-install      # unattended archinstall                -> out/installed.qcow2
make e2e-pre          # pre-bootstrap tests on the installed snapshot
make e2e-bootstrap    # pre tests + bootstrap.sh              -> out/bootstrapped.qcow2
make e2e-post         # post-bootstrap tests + sddm login on the bootstrapped snapshot
make e2e-shell SNAPSHOT=installed|bootstrapped
make e2e-stop
./run.sh exec <snapshot> '<cmd>'   # boot a snapshot, run one command as the user
```

Later stages reuse snapshots, so you can iterate on tests or `bootstrap.sh` without reinstalling.

## How it stays hands-off
- **The ISO under test is the one you burn.** QEMU passes systemd credentials in as SMBIOS OEM strings. `ssh.authorized_keys.root` gives the harness root SSH into the live ISO. `e2e.autorun` makes `/root/.zprofile` (`../autorun.sh`) run `guest/live-install.sh` instead of the interactive flow. Real hardware has neither credential.
- **Test-only differences in the installed system** are kept in `guest/config-overlay.jq`:
  - a fixed disk layout on `/dev/vda`
  - `openssh` + `sshd`
  - the harness key in the user's `authorized_keys`
  - a throwaway password
- **Readiness is polled, never slept for:**
  - the live ISO: SSH, then `/root/e2e/status`
  - the installed system: SSH, then `systemctl is-system-running --wait`
  - the desktop: a `loginctl` wayland session running Hyprland
- **During `bootstrap.sh` only:**
  - a sudoers `!authenticate` shim stands in for the up-front `sudo -v`
  - a fake pinentry stands in for the gpg passphrase prompt

  Both are removed afterwards, and the post tests check that they're gone.
- **Where dotfiles come from:**
  - `E2E_DOTFILES=local` (default): a snapshot of this working tree, including uncommitted and untracked files. It is served from the host over git:// and http, via `BOOTSTRAP_REPO` and a rewritten `.zshrc` URL.
  - `E2E_DOTFILES=github`: tests exactly what a real machine pulls (`main`).

Results are in `out/`:
- `*.tap`: test results
- `install/`: archinstall logs
- `bootstrap.log`, `bootstrap-console.log`
- `*.png`: screenshots
