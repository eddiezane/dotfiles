# Installing

End-to-end recipe for laying this flake down on a Framework 13 AMD. Most steps
generalize; the bits that don't (NVMe device name, hostname, real name, etc.)
are called out.

If you're adapting this to a different machine:
- Add `hosts/<your-host>/` (mirror `hosts/tehunicorn/`).
- Update `mkHost { hostname = "..."; }` in `flake.nix`.
- Adjust `users.nix` (name, SSH keys, `hashedPasswordFile` path).
- Pick an appropriate `nixos-hardware` module for the target laptop.

---

## 1. Boot the installer

Flash a NixOS minimal ISO to a USB stick. Boot the laptop from it (F12 on
Framework's boot menu).

## 2. Get the flake onto the installer

```sh
# (a) Clone from GitHub (if it lives there)
mkdir -p /tmp/nl && cd /tmp/nl
git clone https://github.com/<you>/<repo>.git .

# (b) Copy from a USB stick
sudo mount /dev/sdX1 /mnt && rsync -av /mnt/<repo>/ /tmp/nl/

# (c) rsync from another machine on the LAN
rsync -avz --exclude='.git' <user>@<host>:<path>/ /tmp/nl/
```

## 3. Write the install LUKS passphrase to a file

disko's non-interactive mode needs the passphrase in a file (cryptsetup
otherwise reads `/dev/tty`, which a script can't drive):

```sh
echo -n "<install-passphrase>" | sudo tee /tmp/disko-passphrase >/dev/null
sudo chmod 600 /tmp/disko-passphrase
```

This passphrase will be replaced post-install (step B).

## 4. Format + mount via disko

⚠ Confirm the target disk before running. This wipes it.

```sh
cd /tmp/nl
lsblk     # confirm nvme0n1 is the right disk; adjust hosts/<host>/default.nix's diskoArgs if not
sudo nix --experimental-features 'nix-command flakes' \
  run 'github:nix-community/disko/latest#disko' -- \
  --mode destroy,format,mount \
  --flake '.#<host>' \
  --yes-wipe-all-disks
```

Resulting layout: ESP + LUKS → BTRFS subvols (`@`, `@home`, `@nix`, `@log`,
`@swap`), all mounted under `/mnt`.

## 5. Write the password hash

`users.nix` references `/etc/nixos-secrets/<user>` via `hashedPasswordFile`,
so no hash lives in the repo. Write it while `/mnt` is still mounted:

```sh
sudo mkdir -p /mnt/etc/nixos-secrets
mkpasswd -m sha-512 | sudo tee /mnt/etc/nixos-secrets/<user> >/dev/null
sudo chmod 600 /mnt/etc/nixos-secrets/<user>
```

If this file is missing at activation, `nixos-install` fails — by design,
to avoid silently creating a password-less account.

## 6. Build + install

nix has a long-standing bug with `path:` flake inputs that aborts mid-build
during install. Workaround: ship the flake as a tarball.

```sh
tar --exclude='.git' --mtime='2026-01-01' -czf /tmp/flake.tar.gz .

SYSTEM=$(sudo nix --experimental-features 'nix-command flakes' build \
  "tarball+file:///tmp/flake.tar.gz#nixosConfigurations.<host>.config.system.build.toplevel" \
  --store /mnt --no-write-lock-file --no-link --print-out-paths --refresh)

sudo nixos-install --root /mnt --system "$SYSTEM" \
  --no-root-passwd --no-channel-copy
```

`--no-root-passwd` is fine because root is locked declaratively
(`users.users.root.hashedPassword = "!"`); sudo via the wheel group.

## 7. Reboot

```sh
sudo reboot
# Yank the installer USB at the BIOS splash.
```

First boot prompts for the install LUKS passphrase, then the regreet
greeter. Log in as your declared user. Open a terminal and continue with
the post-install steps below.

---

# Post-install

In order — later steps depend on earlier ones.

## A. Wi-Fi + the flake on disk

NetworkManager is running but no networks are saved:

```sh
nmtui                                              # or: nmcli device wifi connect SSID password 'PW'
ping -c 2 1.1.1.1
```

The flake needs to live at the path `programs.nh.flake` points to (default
`~/Codez/<repo>`):

```sh
mkdir -p ~/Codez
git clone https://github.com/<you>/<repo>.git ~/Codez/<repo>
```

## B. Real LUKS passphrase

Add your real passphrase, then drop the install one:

```sh
sudo cryptsetup luksAddKey /dev/disk/by-partlabel/disk-main-luks
# Enter the install passphrase to unlock, then your real one twice.

sudo cryptsetup luksRemoveKey /dev/disk/by-partlabel/disk-main-luks
# Enter the install passphrase one more time to remove that slot.
```

## C. Hibernation `resume_offset=`

The BTRFS swapfile's physical offset needs to be on the kernel cmdline so
the kernel can find the swap area at resume time:

```sh
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
# prints: Resume offset:    <N>
```

Edit `hosts/<host>/default.nix` and set:

```nix
boot.resumeDevice = "/dev/mapper/cryptroot";
boot.kernelParams = [ "resume_offset=<N>" ];
```

Then:

```sh
nh os switch
systemctl hibernate     # smoke test
```

## D. Secure Boot

`secureBoot.enable = false` on first boot — lanzaboote needs keys before it
can sign anything.

```sh
sudo sbctl create-keys
# Reboot into firmware → clear Platform Key → "Setup Mode" enabled.
# Back in NixOS:
sudo sbctl enroll-keys --microsoft     # keep MS keys for Thunderbolt etc.
```

Flip `secureBoot.enable = true` in your host module:

```sh
nh os switch
sudo sbctl verify              # confirm every EFI image is signed
# Reboot, re-enable "Enforce Secure Boot" in BIOS, save & exit.
sudo sbctl status              # expect: Setup Mode disabled, Secure Boot enabled
```

## E. 1Password SSH agent

In the GUI: **Settings → Developer**
- ✓ Use the SSH agent
- ✓ Integrate with 1Password CLI

Decline 1Password's offers to edit `~/.ssh/config` and `~/.gitconfig` —
home-manager owns those.

Verify:

```sh
echo $SSH_AUTH_SOCK             # should be ~/.1password/agent.sock
ssh-add -l                      # lists exposed pubkeys
ssh -T git@github.com           # smoke test (tap to unlock 1P if prompted)
```

## F. Git commit signing via 1Password

Pick (or create) an SSH signing key in 1Password, copy its public key, then:

```sh
cat > ~/.gitconfig_local <<'EOF'
[user]
  signingkey = key::ssh-ed25519 AAAA... your-comment
EOF
```

Also add the same public key string to `home/<user>/git.nix`'s
`allowed_signers` text (so `git log --show-signature` verifies your own
commits) and rebuild.

Test in a throwaway repo:

```sh
cd /tmp && mkdir sign-test && cd sign-test && git init -b main
git commit --allow-empty -m "sign test"     # 1P will prompt — tap YubiKey
git log --show-signature -1                 # expect: Good "git" signature
```

Optional: upload the same public key to GitHub → Settings → SSH and GPG keys
as a **Signing key** for the "Verified" badge.

## G. YubiKey for sudo (`pam_u2f`)

```sh
mkdir -p ~/.config/Yubico
nix-shell -p pam_u2f --run 'pamu2fcfg > ~/.config/Yubico/u2f_keys'
# Tap when it blinks.

# Backup key (recommended):
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
```

`sudo` now accepts a tap in place of the password (`control = "sufficient"`).

## H. Fingerprint reader

`hardware.sane.enable` + `services.fprintd.enable` are already on. Enroll
a finger:

```sh
fprintd-enroll                  # default right index
fprintd-enroll -f left-index    # add more if you want
```

The flake's PAM stack accepts fingerprint on hyprlock (lockscreen) and sudo.
SDDM/greetd login is password-only by design — physical access boundary.

## I. Tailscale

```sh
sudo tailscale up --operator=$USER
```

To preserve your existing tailnet identity (so SSH known_hosts, ACLs, etc.
keep working), restore `/var/lib/tailscale/` from your backup *before*
running `tailscale up`.

## J. Snapper (optional)

Uncomment the import in `hosts/common.nix`:

```nix
../modules/system/snapshots.nix
```

Then `nh os switch` and verify:

```sh
sudo snapper -c root list
sudo snapper -c home list
```

## K. `/etc/hosts` (hand-managed)

`modules/system/hosts.nix` disables NixOS's generated `/etc/hosts`
(`environment.etc.hosts.enable = false`) so dev/internal host overrides can live
in the file directly — kept out of this public repo and editable without a
rebuild. The trade-off: it's not declarative, so on a fresh install you recreate
it by hand (the boilerplate NixOS used to add is now your responsibility).

After the first `nh os switch`, the managed `/etc/hosts` symlink is gone — seed a
real file (it persists across rebuilds/reboots):

```sh
sudo rm -f /etc/hosts        # drop any leftover managed symlink
sudo tee /etc/hosts >/dev/null <<'EOF'
127.0.0.1   localhost
::1         localhost
127.0.0.2   tehunicorn

# local dev — everything to localhost
127.0.0.1 uds.dev tactical-app.uds.dev keycloak.uds.dev registry.uds.dev mission.uds.dev keycloak.admin.uds.dev sso.uds.dev runtime.admin.uds.dev fleet-command.uds.dev fleet-command-agent-manager.uds.dev

# internal clusters — uncomment as needed (mutually exclusive with the local
# line above for overlapping names; last match wins)
#192.168.x.x  <internal hostnames>
EOF
```

## L. Smoke tests

```sh
systemctl status pipewire wireplumber tailscaled
nmcli device wifi list | head
bluetoothctl show

systemctl --user list-units --type=scope | grep hyprland     # UWSM-scoped session
echo $PATH | tr ':' '\n'                                     # PATH baked in
echo $SSH_AUTH_SOCK $GOPATH $EDITOR
timedatectl | grep zone

sudo systemctl hibernate                                     # resume test
```
