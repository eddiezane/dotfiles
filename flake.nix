{
  description = "tehunicorn - eddiezane's NixOS laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # TEMP: Linux support for the official ChatGPT desktop app. Drop this
    # input and use pkgs.chatgpt once nixpkgs#551713 reaches nixos-unstable.
    chatgpt-nixpkgs.url = "github:NixOS/nixpkgs?ref=pull/551713/head";

    # Hyprland straight from upstream, pinned to a release tag so we get new
    # versions without waiting on the nixpkgs bump. Deliberately NOT following
    # our nixpkgs: modules/system/desktop.nix applies release-specific patches
    # and exposes this package as pkgs.hyprland, while its deps stay on
    # Hyprland's pinned nixpkgs and come from hyprland.cachix.org. `follows`
    # would force a full local rebuild of that dependency tree for no benefit.
    hyprland.url = "github:hyprwm/Hyprland/v0.56.2";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix: unified Catppuccin theming across GTK, Qt, cursors, console, etc.
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-index-database: powers `,` (comma) and `command-not-found` via prebuilt index.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprmod = {
      # TEMP PIN 2026-07-27: upstream packaging bug — hyprmod 0.4.0's pyproject
      # requires hyprland-config>=0.9.13, but their nix/hyprmod.nix INLINE
      # derivation for it (deps not in nixpkgs yet) still pins 0.9.12, so
      # current master cannot build itself. v0.9.13 tag exists upstream; the
      # fix is a version+hash bump in their nix/hyprmod.nix. Pinned to
      # last-good rev; drop the /rev suffix + `nix flake update hyprmod` once
      # they fix it (no existing issue as of pinning — consider filing/PRing).
      url = "github:BlueManCZ/hyprmod/857d0170fec51dffa11cc8827a930121f66dc1e3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    defenseunicorns = {
      url = "git+ssh://git@github.com/defenseunicorns-labs/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, lanzaboote, nixos-hardware, stylix, nix-index-database, hyprmod, defenseunicorns, ... }@inputs:
    let
      system = "x86_64-linux";

      mkHost = { hostname, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostname; };
          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            stylix.nixosModules.stylix
            nix-index-database.nixosModules.nix-index
            ./hosts/common.nix
            ./hosts/${hostname}
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.sharedModules = [
                nix-index-database.homeModules.nix-index
              ];
              home-manager.users.eddiezane = import ./home/eddiezane;
            }
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = {
        tehunicorn = mkHost {
          hostname = "tehunicorn";
          extraModules = [ nixos-hardware.nixosModules.framework-13-7040-amd ];
        };

        # Headless AI server (Ryzen 9 5900X + RTX 3080). No nixos-hardware
        # module — it's a generic desktop board, not a known device profile.
        tehfox = mkHost {
          hostname = "tehfox";
        };

        # Headless Framework server (12th-gen Intel i7-1260P, 64 GB RAM).
        tehbadger = mkHost {
          hostname = "tehbadger";
          extraModules = [ nixos-hardware.nixosModules.framework-12th-gen-intel ];
        };
      };

      # Convenience: `nix fmt`
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
