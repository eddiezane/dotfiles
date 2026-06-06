# Home-manager entry point. Each module is split so it's easy to toggle.
{ pkgs, lib, config, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./wofi.nix
    ./swaync.nix
    ./ghostty.nix
    ./shell.nix
    ./tmux.nix
    ./git.nix
    ./neovim.nix
    ./kubernetes.nix
    ./defenseunicorns.nix
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
    BROWSER = "google-chrome-stable";
    GOPATH = "${config.home.homeDirectory}/Codez/GOPATH";
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
    NIXOS_OZONE_WL = "1";
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
    # Adwaita has no hyprcursor build — xcursor fallback handles everything;
    # leaving HYPRCURSOR_THEME unset lets Hyprland use the xcursor theme.
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/Codez/GOPATH/bin"
    "${config.home.homeDirectory}/.local/share/pnpm/bin"
    "${config.home.homeDirectory}/.cargo/bin" # binaries from `cargo install`
  ];

  # XDG dirs + default openers. xdg-open uses these to pick which app handles
  # a MIME type / scheme. Declare so it doesn't roll dice across reinstalls.
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    setSessionVariables = true; # XDG_DESKTOP_DIR, XDG_DOCUMENTS_DIR, etc.
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "nvim.desktop";
      "text/html" = "google-chrome.desktop";
      "application/pdf" = "google-chrome.desktop";
      "application/json" = "nvim.desktop";
      "application/xml" = "nvim.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "image/jpeg" = "org.gnome.eog.desktop";
      "image/svg+xml" = "org.gnome.eog.desktop";
      "image/gif" = "org.gnome.eog.desktop";
      "video/mp4" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
      "audio/mpeg" = "vlc.desktop";
      "inode/directory" = "thunar.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/mailto" = "google-chrome.desktop";
    };
  };

  # GTK4 / libadwaita apps respect this via gsettings even when not using
  # GNOME — sets the OS-wide dark-mode preference.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
