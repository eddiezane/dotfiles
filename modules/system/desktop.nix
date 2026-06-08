# Wayland session: Hyprland under UWSM + greetd/regreet + portals.
{ pkgs, config, inputs, ... }:

let
  cursor = config.stylix.cursor;
in {
  # System-level Hyprland enable. home-manager owns the actual config files.
  # UWSM = Universal Wayland Session Manager. Required by upstream Hyprland to
  # silence the nag and get systemd-scoped per-app units.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;

    # Hyprland from the upstream flake (pinned to v0.55.3 in flake.nix) rather
    # than nixpkgs, so we're not waiting on the nixpkgs bump. The overrideAttrs
    # carries our local IPC monitor disable→re-enable backstop patch (#14710 /
    # #14447). Applies cleanly on the 0.55.3 tag; upstream's #14547 refactor
    # that supersedes it landed post-release, so drop this once we move past it.
    package = (inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland).overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ../../pkgs/hyprland/scheduleReload-doLater-backstop.patch
      ];
    });
    # Version-matched portal from the same flake (nixpkgs' would lag the tag).
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  programs.uwsm.enable = true;

  # Display manager: greetd + regreet running inside cage.
  #
  # Why not SDDM: SDDM's Wayland greeter uses Weston (which doesn't draw a
  # cursor for kiosk-shell clients) and pulls in kwin_wayland to fix it
  # (~400 MB of KDE). regreet is a GTK4 greeter that runs inside cage
  # (a wlroots-based kiosk compositor) — cleaner, lighter, and the de-facto
  # choice in the Hyprland community.
  #
  # Session picker shows everything in $XDG_DATA_DIRS/wayland-sessions; the
  # Hyprland + Hyprland-UWSM entries are installed by programs.hyprland.enable.
  services.greetd.enable = true;

  # regreet config (theme, cursor, background) and the greetd default_session
  # command (cage -- regreet) come from stylix.targets.regreet, which is on by
  # default. Leave the command alone or stylix's CSS injection breaks.
  programs.regreet.enable = true;

  # XDG desktop portals — Hyprland's own + GTK fallback. The Hyprland portal
  # comes from programs.hyprland.portalPackage above (version-matched to the
  # flake), so it's deliberately not repeated here — only the GTK fallback is.
  xdg.portal = {
    enable = true;
    wlr.enable = false; # hyprland portal supersedes wlr
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # dconf for GTK app settings.
  programs.dconf.enable = true;

  # Allow Wayland-native browsers/electron to launch under Hyprland.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # File manager + thumbnailers. Thunar instead of Nautilus — fewer GNOME deps,
  # ships clean with auto-mount + archive plugins.
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman          # auto-mount removable media
      thunar-archive-plugin  # right-click extract / compress
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Most Hyprland-adjacent packages live in home-manager (home/eddiezane/hyprland.nix).
  # System-level packages here are limited to things that need root, system-wide
  # PATH, or system search paths.
  environment.systemPackages = with pkgs; [
    file-roller     # archive manager (right-click extract for thunar-archive-plugin)
    cursor.package  # cursor theme on the system path so greeter user can find it
  ];
}
