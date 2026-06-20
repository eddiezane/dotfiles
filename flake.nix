{
  description = "tehunicorn - eddiezane's NixOS laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Pin for regreet ONLY. regreet 0.4.0 SIGABRTs at greeter startup with a
    # static-image background — it loads the background as a looping
    # gtk::MediaFile and the Vulkan renderer aborts (OUT_OF_DEVICE_MEMORY),
    # which leaves greetd in a restart loop and no login screen (hit on the
    # 2026-06-12 nixpkgs bump). This rev is the last nixpkgs carrying regreet
    # 0.3.0 (gen 128). Deliberately NOT following nixpkgs — the whole point is
    # to hold regreet back. Drop this node once ReGreet #162 is fixed and
    # nixpkgs ships a working 0.4.x.
    # https://github.com/rharish101/ReGreet/issues/162
    nixpkgs-regreet.url = "github:NixOS/nixpkgs/a799d3e3886da994fa307f817a6bc705ae538eeb";

    # Hyprland straight from upstream, pinned to a release tag so we get new
    # versions without waiting on the nixpkgs bump. Deliberately NOT following
    # our nixpkgs: we patch the hyprland derivation (see modules/system/
    # desktop.nix), so only it rebuilds locally — its deps stay on Hyprland's
    # pinned nixpkgs and come from hyprland.cachix.org. `follows` would force a
    # full local rebuild of that dependency tree for no benefit.
    hyprland.url = "github:hyprwm/Hyprland/v0.55.4";

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

    # Defense Unicorns CLIs (uds, zarf). Built from the official upstream
    # release binaries so SLSA provenance / signed artifacts are preserved.
    # Internal/private repo — use git+ssh:// so we auth via the 1Password
    # SSH agent rather than the public GitHub API (which 404s without auth).
    defenseunicorns = {
      url = "git+ssh://git@github.com/defenseunicorns-labs/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, lanzaboote, nixos-hardware, stylix, nix-index-database, defenseunicorns, ... }@inputs:
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
      };

      # Convenience: `nix fmt`
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
