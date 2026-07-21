# Hyprland configs — links the dotfiles verbatim. These can eventually be
# migrated to home-manager's native `wayland.windowManager.hyprland.settings`.
{ pkgs, ... }:

{
  xdg.configFile."hypr/hyprland.lua".source   = ./dotfiles/hypr/hyprland.lua;
  xdg.configFile."hypr/catppuccin.lua".source = ./dotfiles/hypr/catppuccin.lua;
  xdg.configFile."hypr/xdph.conf".source      = ./dotfiles/hypr/xdph.conf;

  # hypridle / hyprlock — nix-native via home-manager modules.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock --no-fade-in";
        before_sleep_cmd = "loginctl lock-session";
        # A one-shot `hyprctl dispatch 'hl.dsp.dpms("on")'` here races the DRM
        # output re-acquire on resume: hypridle fires it the instant logind
        # sends PrepareForSleep=false, Hyprland accepts it ("ok") before the
        # output is back, and it no-ops — leaving a connected eDP-1 powered down
        # (black screen, dpmsStatus:0, observed on clean s2idle resume
        # 2026-06-27). resume-dpms.sh polls until every enabled monitor reports
        # dpmsStatus:1, so it wins the race regardless of timing. (The script
        # also documents the Lua-parser dispatch-syntax gotcha.)
        after_sleep_cmd = "$HOME/.config/hypr/scripts/resume-dpms.sh";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        # No idle dpms-off listener: on this AMD DCN3.1 box an idle modeset can
        # trigger the `REG_WAIT timeout dcn31_program_compbuf_size` hang (see
        # [[dcn31-compbuf-dpms-hang]]). Let monitor power-management / suspend
        # handle blanking instead. The community-documented mitigation for the
        # AMD blank-lock-screen / REG_WAIT class is exactly this. after_sleep_cmd
        # still restores dpms on resume from suspend.
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      # Fingerprint-at-lock. PAM fprintAuth (security.nix) is necessary but not
      # sufficient on current hyprlock — it also needs fingerprint enabled in
      # its own auth block, otherwise only the password path is active.
      auth = {
        fingerprint = {
          enabled = true;
        };
      };
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
    hyprmod                  # GTK4 settings app (upstream flake)
    hyprpolkitagent          # Hyprland-native polkit agent
    hyprcursor               # native cursor protocol
    wlogout
    rofimoji
    cliphist
    wl-clipboard
    grimblast
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

    # Expose geoclue2's `where-am-i` demo client on PATH so wlsunset.sh can
    # resolve coordinates from geoclue (WiFi/GeoIP via services.geoclue2). The
    # binary otherwise lives in the package's libexec and isn't on PATH.
    (writeShellScriptBin "geoclue-where-am-i"
      ''exec ${geoclue2}/libexec/geoclue-2.0/demos/where-am-i "$@"'')
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
