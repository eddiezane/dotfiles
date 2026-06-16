{ pkgs, ... }:

{
  users.mutableUsers = false; # passwords/keys are declared, not edited at runtime

  users.users.eddiezane = {
    isNormalUser = true;
    description = "Eddie Zaneski";
    shell = pkgs.zsh;
    homeMode = "0755"; # default is 700

    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "render"
      "dialout" # serial / picocom
      "plugdev"
    ];
    # Password hash lives outside the repo. See INSTALL.md for the one-time
    # bootstrap; rotation is the same `mkpasswd | tee` invocation later.
    hashedPasswordFile = "/etc/nixos-secrets/eddiezane";
  };

  # Root account: locked, sudo via wheel.
  users.users.root.hashedPassword = "!";

  # Make sure the secrets dir exists at activation time (the password file
  # itself is written by you out-of-band; activation will fail until it does).
  system.activationScripts.nixos-secrets-dir = ''
    install -d -m 700 /etc/nixos-secrets
  '';

  # Enable zsh at the system level so user shell switching works.
  programs.zsh.enable = true;
}
