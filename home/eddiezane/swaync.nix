{ lib, ... }:

{
  # Enables the upstream swaync.service user unit (WantedBy=graphical-session.target)
  # so UWSM/Hyprland's session starts/stops it — no exec-once needed.
  services.swaync.enable = true;

  # services.swaync always writes its own config.json/style.css (even with no
  # settings passed), so override with mkForce to keep our raw dotfiles.
  xdg.configFile."swaync/config.json".source = lib.mkForce ./dotfiles/swaync/config.json;
  xdg.configFile."swaync/style.css".source   = lib.mkForce ./dotfiles/swaync/style.css;
}
