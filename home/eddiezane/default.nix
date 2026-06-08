# Home-manager entry point. Each module is split so it's easy to toggle.
{ pkgs, lib, config, ... }:

{
  # Base home shared by every host (shell, editor, git, CLI). The Wayland session
  # + GUI apps live in ./desktop.nix, pulled in by the desktop profile.
  imports = [
    ./shell.nix
    ./tmux.nix
    ./git.nix
    ./neovim.nix
    ./kubernetes.nix
    ./packages.nix
  ];

  home.username = "eddiezane";
  home.homeDirectory = "/home/eddiezane";

  # Pinned at install; do not bump without reading the home-manager release notes.
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # nix-index-database integrations: `,` runs anything from nixpkgs without
  # installing, and `command-not-found` taps the prebuilt index.
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  # Session env. These get written to BOTH ~/.config/environment.d/ (consumed
  # by systemd user manager and therefore by UWSM-launched Hyprland apps) AND
  # to your zsh init. systemd's environment.d doesn't expand $HOME, so use the
  # build-time-evaluated `config.home.homeDirectory` to bake in absolute paths.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SYSTEMD_EDITOR = "nvim";
    GOPATH = "${config.home.homeDirectory}/Codez/GOPATH";
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/Codez/GOPATH/bin"
    "${config.home.homeDirectory}/.local/share/pnpm/bin"
    "${config.home.homeDirectory}/.cargo/bin" # binaries from `cargo install`
  ];

  # XDG base + user dirs, declared so they don't drift across reinstalls.
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    setSessionVariables = true; # XDG_DESKTOP_DIR, XDG_DOCUMENTS_DIR, etc.
  };
}
