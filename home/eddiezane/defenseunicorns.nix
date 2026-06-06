# Defense Unicorns CLIs — sourced from our own flake at
# github:defenseunicorns-labs/nix-packages so we get the official upstream
# release binaries (SLSA provenance / signed artifacts preserved).
{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.defenseunicorns.packages.${pkgs.stdenv.hostPlatform.system}.uds-cli
    inputs.defenseunicorns.packages.${pkgs.stdenv.hostPlatform.system}.zarf
  ];
}
