# Desktop/workstation profile: GUI + laptop bundle layered on top of the
# server-safe base (hosts/common.nix). Imported by interactive hosts only
# (tehunicorn); headless hosts like tehfox leave it out.
{ pkgs, ... }:

{
  imports = [
    ../../modules/system/audio.nix
    ../../modules/system/bluetooth.nix
    ../../modules/system/desktop.nix        # Hyprland / greetd / portals
    ../../modules/system/fonts.nix
    ../../modules/system/printing.nix
    ../../modules/system/virtualization.nix # docker + libvirt + virt-manager (GUI)
    ../../modules/system/security.nix        # gnome-keyring, 1Password GUI, fprint/u2f PAM
    ../../modules/system/smartcard.nix
    ../../modules/system/stylix.nix
    ../../modules/system/hardware.nix        # fprintd, PPD, upower, bolt, IIO sensors
    ../../modules/system/hosts.nix           # hand-managed /etc/hosts (dev overrides)
    ../../modules/system/dns-local.nix       # loopback dnsmasq for wildcard dev/internal domains
    ../../modules/system/gaming.nix          # Steam, Proton, Gamescope, gaming tools
    # ../../modules/system/snapshots.nix     # snapper — opt in when wanted
  ];

  # Backport https://github.com/NixOS/nixpkgs/pull/584783 until it reaches
  # our nixos-unstable pin. ChatGPT's Tectonic dependency needs system AWS-LC.
  nixpkgs.overlays = [
    (final: prev: {
      tectonic-unwrapped = prev.tectonic-unwrapped.overrideAttrs (old: {
        buildInputs = [ final.aws-lc ] ++ old.buildInputs;
      });
    })
  ];

  programs.nm-applet.enable = true; # NetworkManager tray applet (GUI)

  # Framework laptop CLI. Useless off a Framework.
  environment.systemPackages = [ pkgs.framework-tool ];

  # Layer the desktop home profile onto eddiezane's base home.
  home-manager.users.eddiezane.imports = [ ../../home/eddiezane/desktop.nix ];
}
