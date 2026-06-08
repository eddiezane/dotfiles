# Settings that apply to every host. Per-host stuff lives in hosts/<name>/.
{ hostname, lib, inputs, ... }:

{
  # Server-safe base shared by every host. GUI/laptop modules and overlays live
  # in hosts/profiles/desktop.nix, layered on top by interactive hosts.
  imports = [
    ../modules/system/boot.nix
    ../modules/system/networking.nix
    ../modules/system/tailscale.nix
    ../modules/system/nix-tools.nix
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
