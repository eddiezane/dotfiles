{
  description = "tehunicorn - eddiezane's NixOS laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Pin for open-webui ONLY. Web search broke after 0.9.4 (still broken on
    # 0.9.6, which nixpkgs-unstable currently ships). This rev is master just
    # before the 0.9.4 -> 0.9.5 bump (#519425), so it carries open-webui 0.9.4.
    # Deliberately NOT following nixpkgs — the point is to hold open-webui back.
    # Drop this node once upstream fixes SearXNG web search and nixpkgs ships it.
    nixpkgs-openwebui.url = "github:NixOS/nixpkgs/99b5236774c1b7f4b0cd92cdd54771d959b507e7";

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
