# Desktop/workstation profile: GUI + laptop bundle layered on top of the
# server-safe base (hosts/common.nix). Imported by interactive hosts only
# (tehunicorn); headless hosts like tehfox leave it out.
{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/system/audio.nix
    ../../modules/system/bluetooth.nix
    ../../modules/system/desktop.nix        # Hyprland / greetd / portals
    ../../modules/system/fonts.nix
    ../../modules/system/printing.nix
    ../../modules/system/virtualization.nix # docker + libvirt + virt-manager (GUI)
    ../../modules/system/security.nix        # gnome-keyring, 1Password GUI, fprint/u2f PAM
    ../../modules/system/stylix.nix
    ../../modules/system/hardware.nix        # fprintd, PPD, upower, bolt, IIO sensors
    ../../modules/system/hosts.nix           # hand-managed /etc/hosts (dev overrides)
    ../../modules/system/dns-local.nix       # loopback dnsmasq for wildcard dev domains (*.uds.dev)
    # ../../modules/system/gaming.nix        # opt in when wanted
    # ../../modules/system/snapshots.nix     # snapper — opt in when wanted
  ];

  # Desktop-only overlays (GUI app patches).
  #
  # Note: the Hyprland IPC monitor disable→re-enable backstop patch (#14710)
  # used to live here as an overlay on pkgs.hyprland. It now rides on the
  # upstream flake package via programs.hyprland.package in
  # modules/system/desktop.nix, since that's the package the session actually
  # runs — patching pkgs.hyprland here would have been a no-op for the session.
  nixpkgs.overlays = [
    inputs.hyprmod.overlays.default
  ];

  programs.nm-applet.enable = true; # NetworkManager tray applet (GUI)

  # Framework laptop CLI. Useless off a Framework.
  environment.systemPackages = [ pkgs.framework-tool ];

  # Layer the desktop home profile onto eddiezane's base home.
  home-manager.users.eddiezane.imports = [ ../../home/eddiezane/desktop.nix ];
}
