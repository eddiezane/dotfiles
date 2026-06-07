# Settings that apply to every host. Per-host stuff lives in hosts/<name>/.
{ hostname, lib, inputs, ... }:

{
  imports = [
    ../modules/system/boot.nix
    ../modules/system/hardware.nix
    ../modules/system/networking.nix
    ../modules/system/hosts.nix
    ../modules/system/audio.nix
    ../modules/system/bluetooth.nix
    ../modules/system/desktop.nix
    ../modules/system/fonts.nix
    ../modules/system/printing.nix
    ../modules/system/virtualization.nix
    ../modules/system/tailscale.nix
    ../modules/system/security.nix
    # ../modules/system/snapshots.nix   # snapper — opt in when wanted
    ../modules/system/nix-tools.nix
    ../modules/system/stylix.nix
    # ../modules/system/gaming.nix
    ../modules/system/packages.nix
    ../modules/system/users.nix
  ];

  networking.hostName = hostname;

  # Enable flakes + nix command
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    # TEMP: signal-desktop from nixpkgs' nixos-26.05 backport channel, which
    # ships the current release ahead of nixos-unstable (whose channel pointer
    # lags master). Drop this overlay and the `nixpkgs-signal` flake input once
    # nixos-unstable catches up — check with
    # `nix eval --refresh --raw github:NixOS/nixpkgs/nixos-unstable#signal-desktop.version`.
    (final: prev: {
      signal-desktop = inputs.nixpkgs-signal.legacyPackages.${prev.system}.signal-desktop;
    })

    # TEMP: local Hyprland patch for the IPC monitor disable→re-enable bug
    # (#14710). scheduleReload only fires through render.preChecks, which
    # doesn't tick in unsafe state — so a `hyprctl keyword monitor X,
    # preferred, …` re-enable silently no-ops until something else
    # triggers a config reload. Patch adds a doLater backstop so the
    # reload always fires. See pkgs/hyprland/scheduleReload-doLater-backstop.patch
    # for the full rationale. Remove once an equivalent fix lands upstream.
    (final: prev: {
      hyprland = prev.hyprland.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../pkgs/hyprland/scheduleReload-doLater-backstop.patch
        ];
      });
    })

    # TEMP: local packaging of hyprmod (GTK4 settings app for Hyprland) and its
    # five Python library deps, tracking nixpkgs PR #505419. Built at the latest
    # upstream releases (hyprmod 0.3.0); the PR pins 0.2.0. The five libraries go
    # through pythonPackagesExtensions so they land in every interpreter's
    # package set (python3Packages.hyprland-*), which hyprmod's
    # buildPythonApplication then consumes. Remove this overlay and pkgs/hyprmod/
    # once the PR merges and the version reaching us is >= what we want.
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyfinal: pyprev: {
          hyprland-socket = pyfinal.callPackage ../pkgs/hyprmod/hyprland-socket.nix { };
          hyprland-schema = pyfinal.callPackage ../pkgs/hyprmod/hyprland-schema.nix { };
          hyprland-config = pyfinal.callPackage ../pkgs/hyprmod/hyprland-config.nix { };
          hyprland-monitors = pyfinal.callPackage ../pkgs/hyprmod/hyprland-monitors.nix { };
          hyprland-state = pyfinal.callPackage ../pkgs/hyprmod/hyprland-state.nix { };
        })
      ];

      hyprmod = final.callPackage ../pkgs/hyprmod/package.nix { };
    })
  ];

  services.automatic-timezoned.enable = true;
  location.provider = "geoclue2";
  services.geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";

  i18n.defaultLocale = "en_US.UTF-8";

  networking.timeServers = [
    "time.google.com"
    "time2.google.com"
    "time3.google.com"
    "time4.google.com"
  ];

  # Pinned at install; do not bump without reading the NixOS release notes.
  system.stateVersion = "25.11";
}
