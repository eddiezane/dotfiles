# Stylix — one source of truth for Catppuccin Macchiato across GTK, Qt,
# cursors, console, fonts, and any stylix-aware app added later.
#
# We intentionally DISABLE stylix's targets for apps where we already maintain
# explicit dotfiles (hyprland, waybar, swaync, wofi, ghostty). Stylix would
# otherwise fight our `xdg.configFile.<...>.source` symlinks.
{ pkgs, lib, ... }:

let
  # base16 palette for Catppuccin Macchiato (the source of truth for stylix).
  macchiato = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

  # A solid-color wallpaper as a stand-in until you drop a real image at
  # ./assets/wallpaper.png — stylix requires *some* image attribute.
  placeholderWallpaper = pkgs.runCommand "wallpaper-macchiato.png"
    { nativeBuildInputs = [ pkgs.imagemagick ]; }
    ''magick -size 3840x2160 xc:'#24273a' $out'';
in
{
  stylix = {
    enable = true;
    polarity = "dark";
    image = placeholderWallpaper;
    base16Scheme = macchiato;

    cursor = {
      # Plain Adwaita. GNOME bundles it via gnome-themes-extra; the standalone
      # package is adwaita-icon-theme.
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "SauceCodePro Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        terminal = 13;
        desktop = 11;
        popups = 11;
      };
    };

    # Disable targets we already hand-roll. Stylix still themes everything
    # else (GTK4/libadwaita color-scheme, Qt, console, btop, fzf, vim, etc.).
    targets = {
      grub.enable = false; # systemd-boot, not grub
      # Stylix's chromium target writes a managed-policy JSON to
      # /etc/opt/chrome/policies/managed/ which (a) makes Chrome show
      # "Your administrator has set a default theme" and (b) blocks
      # manual theme selection. We want neither.
      chromium.enable = false;
      # nixpkgs 26.05 removed services.kmscon.extraConfig and .fonts in
      # favor of services.kmscon.config / fonts.packages. Stylix's kmscon
      # target still writes the old options, breaking eval. We don't run
      # kmscon anyway. Remove once stylix ports its module upstream.
      kmscon.enable = false;
    };
  };

  # Per-user (home-manager) stylix targets toggled where dotfiles already exist.
  home-manager.sharedModules = [
    ({ ... }: {
      stylix.targets = {
        hyprland.enable = false;
        hyprlock.enable = false; # we own background + input-field via programs.hyprlock
        waybar.enable = false;
        swaync.enable = false;
        wofi.enable = false;
        ghostty.enable = false; # we ship the catppuccin theme file
        tmux.enable = false;    # explicit tmux config in ./dotfiles/tmux
        neovim.enable = false;  # AstroNvim handles its own theme; stylix would
                                # overwrite the user's init.lua with mini.base16
      };
    })
  ];
}
