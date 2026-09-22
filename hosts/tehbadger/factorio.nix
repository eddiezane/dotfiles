# Factorio dedicated server for tehbadger.
{
  lib,
  pkgs,
  ...
}:
let
  # The headless distribution includes the Space Age DLC. Keep this explicit
  # so coworkers who only own the base game can join.
  baseGameModList = pkgs.writeText "factorio-base-game-mod-list.json" (
    builtins.toJSON {
      mods = [
        {
          name = "base";
          enabled = true;
        }
        {
          name = "elevated-rails";
          enabled = false;
        }
        {
          name = "quality";
          enabled = false;
        }
        {
          name = "space-age";
          enabled = false;
        }
      ];
    }
  );
in
{
  services.factorio = {
    enable = true;

    # Listen on Factorio's default game port. Forward UDP/34197 on the router
    # as well if players will connect from outside the LAN or tailnet.
    openFirewall = true;

    # Generate world.zip on first start, then recover the newest autosave after
    # a crash or desync instead of always loading the original save.
    saveName = "world";
    loadLatestSave = true;

    game-name = "tehbadger";
    description = "Factorio on tehbadger";

    # Keep the server off the public matching service until credentials and an
    # optional game password are provisioned. Players can connect directly.
    public = false;
    lan = true;
  };

  systemd.services.factorio = {
    # Factorio verifies players with factorio.com even when the game is not
    # publicly listed, so wait until NetworkManager has completed startup.
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    # Avoid systemd's start-rate limit if external DNS or factorio.com is
    # temporarily unavailable after the local network comes online.
    serviceConfig.RestartSec = "30s";

    # nixpkgs#423952 will eventually make the mod list a first-class service
    # option. Until then, install it before the module creates or loads a save.
    preStart = lib.mkBefore ''
      ${pkgs.coreutils}/bin/install -Dm600 \
        ${baseGameModList} \
        /var/lib/factorio/mods/mod-list.json
    '';
  };
}
