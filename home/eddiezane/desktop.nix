# Desktop home profile: Wayland session (Hyprland/waybar/wofi/swaync/ghostty),
# GUI apps, and desktop-only env (browser, MIME handlers, dark mode, 1Password
# agent socket). Pulled in by hosts/profiles/desktop.nix on interactive hosts;
# the base (home/eddiezane/default.nix) carries the shared shell/CLI environment.
{ pkgs, config, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./wofi.nix
    ./swaync.nix
    ./ghostty.nix
    ./defenseunicorns.nix  # uds/zarf (private flake input)
  ];

  home.packages = with pkgs; [
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
    rapidraw

    # JetBrains IDEs (all-you-can-eat license).
    jetbrains.goland
    # The bundled Android emulator is a Qt app that ships no Wayland platform
    # plugin (only offscreen/linuxfb/minimal/xcb/vnc). With the session-wide
    # QT_QPA_PLATFORM=wayland it SIGABRTs on launch with no dialog, so AVDs
    # "fail to start" silently. Force xcb (XWayland) for the Studio process
    # tree; bwrap inherits the env, so the emulator subprocess picks it up too.
    (symlinkJoin {
      name = "android-studio";
      paths = [ android-studio ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/android-studio \
          --set QT_QPA_PLATFORM xcb
      '';
    })

    obs-studio
    qalculate-qt
    qdirstat
    gnome-disk-utility
    nwg-displays
    nwg-look
    popsicle
  ];

  # Desktop-only session env (SSH_AUTH_SOCK → 1Password agent, workstation-only).
  home.sessionVariables = {
    BROWSER = "google-chrome-stable";
    NIXOS_OZONE_WL = "1";
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
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
