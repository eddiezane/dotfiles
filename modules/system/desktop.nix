# Wayland session: Hyprland under UWSM + greetd/tuigreet + portals.
{ pkgs, config, inputs, ... }:

let
  cursor = config.stylix.cursor;
in {
  # Keep one authoritative Hyprland package across the desktop configuration.
  # The session uses pkgs.hyprland below, and this overlay also makes nixpkgs
  # consumers such as grimblast resolve their hyprctl from that same package.
  nixpkgs.overlays = [
    (final: _prev: {
      hyprland = (inputs.hyprland.packages.${final.stdenv.hostPlatform.system}.hyprland).overrideAttrs (old: {
        # TEMP 2026-08-05: v0.56.2's pinned nixpkgs provides glaze 8, but
        # the release still restricts CMake discovery to glaze 7.x and
        # falls back to an impossible FetchContent clone in the Nix sandbox.
        # Mirrors nixpkgs #549253 / Hyprland 91f29f2; remove once a release
        # containing the upstream fix is pinned.
        postPatch = ''
          substituteInPlace CMakeLists.txt start/CMakeLists.txt hyprpm/CMakeLists.txt \
            --replace-fail "glaze 7...<8" "glaze"
        '' + (old.postPatch or "");
      });
    })
  ];

  # System-level Hyprland enable. home-manager owns the actual config files.
  # UWSM = Universal Wayland Session Manager. Required by upstream Hyprland to
  # silence the nag and get systemd-scoped per-app units.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;

    package = pkgs.hyprland;
    # Version-matched portal from the same flake (nixpkgs' would lag the tag).
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  programs.uwsm.enable = true;

  # Display manager: greetd + tuigreet (TUI greeter, runs in the TTY).
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
      user = "greeter";
    };
  };

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

  # libgphoto2 udev rules — tag PTP cameras (Canon EOS etc.) with ID_GPHOTO2=1.
  # gvfs's gphoto2 volume monitor discovers cameras via that udev tag, NOT by
  # probing with gphoto2. Without these rules the camera still works via the
  # `gphoto2` CLI and a manual `gphoto2://` mount, but never auto-mounts or shows
  # up in Thunar's sidebar on plug. The default-installed 70-camera.rules (V4L
  # webcams) and 69-libmtp.rules (MTP) don't match a PTP still camera. The rules
  # ship in pkgs.libgphoto2 (lib/udev/rules.d/40-libgphoto2.rules, line matching
  # USB interface 06/01/01 → ENV{ID_GPHOTO2}="1").
  services.udev.packages = [ pkgs.libgphoto2 ];

  # Most Hyprland-adjacent packages live in home-manager (home/eddiezane/hyprland.nix).
  # System-level packages here are limited to things that need root, system-wide
  # PATH, or system search paths.
  environment.systemPackages = with pkgs; [
    file-roller     # archive manager (right-click extract for thunar-archive-plugin)
    cursor.package
  ];
}
