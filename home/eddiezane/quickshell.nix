{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.quickshell ];
  xdg.configFile."quickshell/dotfiles".source = ./dotfiles/quickshell;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell status bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" "wayland-session-waitenv.service" ];
      Requisite = [ "graphical-session.target" ];
      X-Restart-Triggers = [ "${./dotfiles/quickshell}" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs --config dotfiles --no-duplicate";
      Environment = [
        "PATH=${lib.makeBinPath [ pkgs.python3 pkgs.brightnessctl pkgs.swaynotificationcenter pkgs.pavucontrol pkgs.systemd ]}:/etc/profiles/per-user/eddiezane/bin:/run/current-system/sw/bin"
      ];
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
