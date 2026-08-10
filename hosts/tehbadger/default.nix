# tehbadger — headless Framework server.
# Plain Btrfs keeps the first install simple; add encryption once the machine
# has a reliable remote-unlock/recovery plan.
{
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/disko/btrfs.nix
    ../../modules/system/k0s.nix
    ./hardware.nix
  ];

  # Dedicated machine with one internal NVMe. Verify this is the 1 TB 980 PRO
  # from the installer before running disko; the command will erase it.
  # After installation, this can be changed to the stable /dev/disk/by-id/
  # nvme-* path shown by `ls -l /dev/disk/by-id`.
  _module.args.diskoArgs = {
    disk = "/dev/nvme0n1";
    swapSize = "16G";
    espSize = "1G";
  };

  # Remote access is Tailscale SSH only. Bootstrap it once at the physical
  # console with `sudo tailscale up --ssh` after the first boot.
  services.openssh.enable = false;
  services.tailscale.extraUpFlags = [ "--ssh" ];

  # Containers are the likely home for Pi-hole and smaller self-hosted apps.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
  virtualisation.libvirtd.enable = true;
  users.users.eddiezane.extraGroups = [
    "docker"
    "libvirtd"
    "kvm"
  ];

  # The shared home profile already supplies Codex, Go, Docker Compose, Git/gh,
  # Nix/direnv, Neovim, and Kubernetes tooling. Add the DU CLI bundle that the
  # desktop home imports separately, without pulling any GUI packages onto this
  # host. Use OpenSSH for commit signing instead of the desktop's 1Password
  # signing helper; ~/.gitconfig_local can point user.signingkey at the key that
  # is provisioned on tehbadger.
  home-manager.users.eddiezane = {
    imports = [ ../../home/eddiezane/defenseunicorns.nix ];
    programs.git.settings.gpg.ssh.program = lib.mkForce "${pkgs.openssh}/bin/ssh-keygen";
  };

  services.fwupd.enable = true;
  services.smartd.enable = true;
  services.fstrim.enable = true;

  services.k0s = {
    enable = true;
    singleNode = true;
  };

}
