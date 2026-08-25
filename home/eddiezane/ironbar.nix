{ inputs, pkgs, ... }:

let
  ironbar = inputs.ironbar.packages.${pkgs.stdenv.hostPlatform.system}.default;

  temperatureTooltip = pkgs.writeShellScript "ironbar-temperature-tooltip" ''
    readings="$(sensors 2>/dev/null | awk '
      /^k10temp-/ { source = "cpu"; next }
      /^nvme-/ { source = "nvme"; next }
      /^framework_laptop-/ { source = "fan"; next }
      source == "cpu" && /Tctl:/ { cpu = $2; source = "" }
      source == "nvme" && /Composite:/ { nvme = $2; source = "" }
      source == "fan" && /fan1:/ { fan = $2 " " $3; source = "" }
      END {
        if (cpu) print "CPU: " cpu
        if (nvme) print "NVMe: " nvme
        if (fan) print "Fan: " fan
      }
    ')"

    if [ -n "$readings" ]; then
      printf '%s\n' "$readings"
    else
      printf 'No temperature sensor data\n'
    fi
  '';
in
{
  # Keep Ironbar's lifecycle tied to the UWSM graphical session.
  systemd.user.services.ironbar = {
    Unit = {
      Description = "Ironbar Wayland status bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${ironbar}/bin/ironbar";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.packages = [ ironbar ];

  xdg.configFile = {
    "ironbar/config.json".source = ./dotfiles/ironbar/config.json;
    "ironbar/style.css".source = ./dotfiles/ironbar/style.css;
    "ironbar/macchiato.css".source = ./dotfiles/waybar/macchiato.css;
    "ironbar/scripts/power-profile.sh".source = ./dotfiles/ironbar/scripts/power-profile.sh;
    "ironbar/scripts/temperature-tooltip.sh".source = temperatureTooltip;
  };
}
