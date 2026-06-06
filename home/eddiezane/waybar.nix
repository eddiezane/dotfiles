{ lib, ... }:

{
  # Enables the upstream waybar.service user unit (WantedBy=graphical-session.target)
  # so UWSM/Hyprland's session starts/stops it — no exec-once needed.
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # programs.waybar may write its own config/style; mkForce to keep our raw
  # dotfiles (waybar config uses JS-style comments, can't round-trip through
  # programs.waybar.settings as a nix attrset without losing them).
  xdg.configFile."waybar/config".source        = lib.mkForce ./dotfiles/waybar/config;
  xdg.configFile."waybar/style.css".source     = lib.mkForce ./dotfiles/waybar/style.css;
  xdg.configFile."waybar/macchiato.css".source = ./dotfiles/waybar/macchiato.css;
}
