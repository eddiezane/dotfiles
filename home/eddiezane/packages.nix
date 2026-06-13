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
    openssl
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
    mise
    pnpm
    # Kubernetes tools (kubectl, helm, k9s, kind, k3d, skopeo) -> kubernetes.nix
  ];
}
