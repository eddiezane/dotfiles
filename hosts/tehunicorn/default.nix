# Framework laptop.
{ lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/desktop.nix
    ../../modules/disko/luks-btrfs.nix
    ./hardware.nix
    ./hibernate-debug.nix
  ];

  _module.args.diskoArgs = {
    disk = "/dev/nvme0n1";
    swapSize = "96G"; # >= RAM (86G usable) so hibernation works
    espSize = "1G";
  };

  # Used by disko + boot to wire `resume=` to the BTRFS-hosting block device,
  # along with the swapfile's resume_offset that disko computes for us.
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/disk-main-luks";

  # Hibernation: resume from the swapfile inside the LUKS-backed BTRFS.
  # Offset computed once post-install via:
  #   sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume_offset=533760" ];

  secureBoot.enable = true;

  # SMART monitoring on the NVMe.
  services.smartd.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Suspend for ~30 min, then hibernate.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
    SuspendState = "mem";
  };

  # nixos-hardware's framework module enables TLP; we use tuned instead.
  services.tlp.enable = false;
}
