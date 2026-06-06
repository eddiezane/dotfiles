# User-level packages. Per-project devShells (flake.nix + nix-direnv) cover
# language toolchains for individual repos; this list is for things that
# should be globally available.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI utilities
    btop
    direnv
    gnupg
    htop
    inotify-tools
    jq
    noti
    pinentry-gnome3
    pwgen
    ripgrep
    rsync
    sshfs
    tldr
    tree
    yq-go

    # Dev tooling (keep this list light; per-project devshells are the nix way)
    claude-code
    docker-compose
    gh
    go
    gopls
    gotools
    go-containerregistry
    melange
    # Kubernetes tools (kubectl, helm, k9s, kind, k3d, skopeo) -> kubernetes.nix

    # GUI utilities for the desktop session
    firefox
    google-chrome
    signal-desktop
    slack
    # Electron's safe-storage auto-detection picks `basic` on Hyprland, which
    # breaks plugins that store secrets (e.g. obsidian-todoist). Force the
    # gnome-libsecret backend so creds land in gnome-keyring.
    (symlinkJoin {
      name = "obsidian";
      paths = [ obsidian ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/obsidian \
          --add-flags "--password-store=gnome-libsecret"
      '';
    })
    spotify
    vlc

    # JetBrains IDEs (all-you-can-eat license).
    jetbrains.goland
    android-studio

    # Streaming / recording
    obs-studio
    qalculate-qt
    qdirstat
    gnome-disk-utility
    nwg-displays
    nwg-look
  ];
}
