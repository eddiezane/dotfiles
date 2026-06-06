{
  description = "tehunicorn - eddiezane's NixOS laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
      };

      # Convenience: `nix fmt`
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
