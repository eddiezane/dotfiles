{ pkgs, ... }:

{
  # gnome-keyring is still useful for secret-service (browsers, GTK apps).
  # Both SSH auth and git commit signing go through 1Password's SSH agent —
  # no gpg-agent needed. If you ever need ad-hoc `gpg --decrypt`, install gnupg
  # in home.packages and it'll spawn a transient agent on demand.
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  # PolicyKit agent (replacement for polkit-gnome started from hyprland).
  security.polkit.enable = true;

  # PAM:
  # - sudo + hyprlock can use the Framework fingerprint reader.
  # - greetd + login auto-unlock the gnome-keyring on successful auth, so
  #   secrets are available to browsers/git/etc without a second password prompt.
  # NixOS auto-enables u2fAuth/fprintAuth on every PAM service when those
  # modules are globally enabled. That's not what we want — be explicit about
  # which surface accepts which factor.
  #
  # sudo:     YubiKey OR fingerprint OR password
  # hyprlock: fingerprint OR password  (no YubiKey — tap shouldn't wake the box)
  # polkit-1: fingerprint OR password  (1Password unlock authorizes via polkit;
  #           no YubiKey tap — see note below)
  # greetd:   password only            (physical-access boundary; once per cold boot)
  # login:    password only            (tty / console)
  security.pam.services = {
    sudo = {
      u2fAuth = true;
      fprintAuth = true;
    };
    hyprlock = {
      u2fAuth = false;
      fprintAuth = true;
    };
    # 1Password's "unlock with system authentication" authorizes a polkit
    # action, so it runs the `polkit-1` PAM stack. Left unconfigured it
    # inherits the globals (u2fAuth + fprintAuth both on), which is why the
    # prompt offers a YubiKey tap. Match hyprlock: fingerprint OR password.
    "polkit-1" = {
      u2fAuth = false;
      fprintAuth = true;
    };
    greetd = {
      u2fAuth = false;
      fprintAuth = false;
      enableGnomeKeyring = true;
    };
    login = {
      u2fAuth = false;
      fprintAuth = false;
      enableGnomeKeyring = true;
    };
  };

  # YubiKey FIDO/U2F. First-boot one-time setup:
  #   nix-shell -p pam_u2f --run 'pamu2fcfg > ~/.config/Yubico/u2f_keys'
  # That writes your YubiKey's public-key registration. Tap the key when it blinks.
  security.pam.u2f = {
    enable = true;
    settings = {
      cue = true;
      # "sufficient" = touch YubiKey OR enter password. "required" = both.
      control = "sufficient";
    };
  };

  # Desktop notification whenever anything is waiting on a YubiKey touch
  # (sudo, hyprlock, ssh-add, gpg). Module enables the upstream user units
  # + libnotify env var, wired to graphical-session.target. The module only
  # registers the systemd units (systemd.packages); explicitly install the
  # package so share/icons/hicolor/.../yubikey-touch-detector.png ends up on
  # XDG_DATA_DIRS and swaync can render the notification icon.
  programs.yubikey-touch-detector.enable = true;
  environment.systemPackages = [ pkgs.yubikey-touch-detector ];

  # Sudo: keep password but cache for a while.
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=15
  '';

  # 1Password — declare the GUI + CLI as system tools so polkit + browser ints work.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "eddiezane" ];
  };
}
