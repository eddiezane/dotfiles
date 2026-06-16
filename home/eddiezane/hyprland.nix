# Hyprland configs — links the dotfiles verbatim. These can eventually be
# migrated to home-manager's native `wayland.windowManager.hyprland.settings`.
{ pkgs, ... }:

{
  xdg.configFile."hypr/hyprland.lua".source   = ./dotfiles/hypr/hyprland.lua;
  xdg.configFile."hypr/catppuccin.lua".source = ./dotfiles/hypr/catppuccin.lua;

  # hypridle / hyprlock — nix-native via home-manager modules.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock --no-fade-in";
        before_sleep_cmd = "loginctl lock-session";
        # The Lua parser dropped legacy `hyprctl dispatch dpms on` (it reparses
        # as the invalid `hl.dispatch(dpms on)` and silently no-ops). Under Lua,
        # `hyprctl dispatch` is shorthand for `eval 'hl.dispatch(...)'`, so call
        # the dispatcher from the hl.dsp namespace directly.
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 360;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms(\"off\")'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      background = [{
        monitor = "";
        color = "rgb(0,0,0)";
      }];
      input-field = [{
        monitor = "";
        size = "200, 50";
        outline_thickness = 3;
        dots_size = 0.33;
        dots_spacing = 0.15;
        dots_center = false;
        dots_rounding = -1;
        outer_color = "rgb(151515)";
        inner_color = "rgb(200, 200, 200)";
        font_color = "rgb(10, 10, 10)";
        fade_on_empty = true;
        fade_timeout = 1000;
        placeholder_text = "<i>Input Password...</i>";
        hide_input = false;
        rounding = -1;
        check_color = "rgb(204, 136, 34)";
        fail_color = "rgb(204, 34, 34)";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = -1;
        numlock_color = -1;
        bothlock_color = -1;
        invert_numlock = false;
        swap_font_color = false;
        position = "0, -20";
        halign = "center";
        valign = "center";
      }];
    };
  };

  # wlogout layout — uses `uwsm stop` for clean session teardown instead of the
  # default `loginctl terminate-user` (which force-kills UWSM and crashes SDDM).
  xdg.configFile."wlogout/layout".source = ./dotfiles/wlogout/layout;

  # Scripts as executable copies (xdg.configFile.source defaults to read-only symlinks;
  # using a directory + recursive makes them browseable but still managed).
  xdg.configFile."hypr/scripts" = {
    source = ./dotfiles/hypr/scripts;
    recursive = true;
  };

  # Packages used by the Hyprland config and the helper scripts. Anything with a
  # corresponding `programs.<x>` / `services.<x>` enable in this or its sibling
  # modules pulls its own package, so they're intentionally not repeated here:
  #   - hypridle  (services.hypridle.enable)
  #   - hyprlock  (programs.hyprlock.enable)
  #   - wofi      (programs.wofi.enable)
  #   - waybar    (programs.waybar.enable — waybar.nix)
  #   - swaync    (services.swaync.enable — swaync.nix)
  home.packages = with pkgs; [
    hyprpaper
    hyprpicker
    hyprmod                  # GTK4 settings app (local pkg; tracks nixpkgs PR #505419)
    hyprpolkitagent          # Hyprland-native polkit agent
    hyprcursor               # native cursor protocol
    wlogout
    rofimoji
    cliphist
    wl-clipboard
    grim
    slurp
    satty
    brightnessctl
    wlsunset
    playerctl
    pamixer
    pavucontrol
    pwvucontrol              # pipewire-native mixer
    networkmanagerapplet
    libnotify

    # Debug helper for when Hyprland wedges post-hibernate-resume. SSH in
    # from phone, run `hypr-stall-capture`, then reboot cleanly. Source of
    # truth is the .sh file in dotfiles so it stays diffable.
    (writeShellScriptBin "hypr-stall-capture"
      (builtins.readFile ./dotfiles/hypr/scripts/hypr-stall-capture.sh))
  ];

  # hyprpolkitagent ships its own systemd user service; just enable it.
  # UWSM picks it up as part of the session.
  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit authentication agent";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
