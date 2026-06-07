# nix-ld + nh + nix-index — modern NixOS dev-laptop ergonomics.
{ pkgs, inputs, ... }:

{
  # nix-ld: lets dynamically-linked binaries that weren't built for NixOS run
  # (VSCode Server, prebuilt language toolchains, mise-downloaded binaries,
  # random vendor blobs). The library list is the "good default" set; expand
  # if a tool complains about missing libs.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      libgcc
      curl
      glib
      glibc
      icu
      libxml2
      libxslt
      nss
      nspr
      libsecret
      util-linux
    ];
  };

  # nh: prettier nixos-rebuild + integrated `nh clean` for GC.
  programs.nh = {
    enable = true;
    flake = "/home/eddiezane/Codez/dotfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 14d --keep 5";
    };
  };

  # nix-index-database: replaces command-not-found's stale database with a
  # weekly-refreshed prebuilt index. Per-user `programs.nix-index.enable` lives
  # in home-manager.
  programs.command-not-found.enable = false;

  # Less noise from `nix` during local iteration.
  nix.settings.warn-dirty = false;

  # nix-output-monitor (`nom`) + nix-tree for inspecting closures.
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nix-tree
  ];
}
