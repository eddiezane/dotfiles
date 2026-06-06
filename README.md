# tehunicorn — NixOS configuration

Personal flake-based NixOS configuration for a Framework 13 (AMD Ryzen 7
7840U). Public so other people building similar laptops can mine it for
ideas — feel free to copy whatever's useful.

For the step-by-step install, see [INSTALL.md](./INSTALL.md).

## Stack at a glance

| Layer | Choice |
|---|---|
| Disk | LUKS → BTRFS (subvols `@`, `@home`, `@nix`, `@log`, `@swap`) — no LVM |
| Hibernation | BTRFS swapfile in a NoCoW subvol, ≥ RAM (96 GB) |
| Boot | systemd-boot + lanzaboote (Secure Boot, declaratively signed) |
| Display manager | greetd + regreet, running inside cage |
| Compositor | Hyprland under UWSM |
| Bar / notifications / launcher | waybar / swaync / wofi |
| Theming | stylix (Catppuccin Macchiato) — GTK, Qt, cursors, console, etc. |
| Terminal | ghostty + tmux |
| Editor | neovim (AstroNvim, plugin-managed by Lazy) |
| File manager | Thunar (+ volman, archive plugin) |
| Polkit agent | hyprpolkitagent |
| Audio | PipeWire (alsa + pulse + jack) |
| SSH agent | 1Password, via `~/.1password/agent.sock` |
| Git commit signing | SSH-based, signed by 1Password's `op-ssh-sign` |
| YubiKey | FIDO/U2F only — `pam_u2f` on sudo. Fingerprint on lockscreen. |
| Tool versioning | per-project devShells (`flake.nix` + `direnv` + `nix-direnv`) |
| Snapshots | snapper (opt-in; layout is ready) |
| Secrets | password hash kept outside the repo via `hashedPasswordFile` |
| Dotfiles | home-manager — native `programs.*` where possible, raw files via `xdg.configFile` for the rest |

## Layout

```
flake.nix                       Inputs + host wiring
hosts/
  common.nix                    Shared NixOS settings
  tehunicorn/                   This laptop (resume offset, lid switch, etc.)
modules/
  disko/luks-btrfs.nix          Declarative disk layout
  system/                       boot, audio, networking, bluetooth, desktop, etc.
pkgs/
  signal-desktop-deb/           .deb override (nixos-unstable trails the openable version)
  hyprland/                     Local Hyprland patch (IPC monitor re-enable backstop)
  hyprmod/                      Local hyprmod + Python deps (tracks nixpkgs PR #505419)
home/eddiezane/
  default.nix                   Home-manager entrypoint
  hyprland.nix waybar.nix ...   One file per surface
  dotfiles/                     Hand-tuned configs (hyprland.conf, waybar, swaync)
```

## Day-to-day

```sh
nh os switch                    # rebuild + activate (default)
nh os boot                      # build, set default on next boot, don't activate now
nh os build --diff              # dry-run with package diff
nh os switch --rollback         # back to previous generation

home-manager switch --flake .#eddiezane@tehunicorn   # rebuild home only (no root)

nix flake update                     # bump all inputs
nix flake update nixpkgs             # bump just one input

nh clean all                    # GC old generations + store paths
```

## Troubleshooting

**`Assertion ... originalInput.getNarHash()` aborts during rebuild.** Known
nix bug with `path:` flake inputs after the source directory is touched.
The fix is almost always: commit (or stash) outstanding changes so nix uses
`git+file://` instead of `path:`. If that's not enough:

```sh
rm -rf ~/.cache/nix && sudo rm -rf /root/.cache/nix
```

If the bug shows up at install time (before the repo is a git tree), build
via a tarball flake — see INSTALL.md.
