# Framework laptop.
{ lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/desktop.nix
    ../../modules/disko/luks-btrfs.nix
    ./hardware.nix
    # TEMP disabled 2026-08-11: the local TTM membership patch proved
    # incomplete after another post-hibernate scanline freeze. Keep the module
    # out until drm/amd#5387 has an upstream fix we trust.
    # ./hibernate-debug.nix
  ];

  _module.args.diskoArgs = {
    disk = "/dev/nvme0n1";
    swapSize = "96G"; # Retained for future hibernation; also normal swap.
    espSize = "1G";
  };

  # LUKS backing device for the root filesystem and retained swapfile.
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/disk-main-luks";

  # TEMP: disable hibernation and image restore in the kernel. Keep the RTC
  # alarm quirk from hibernate-debug.nix because plain s2idle still uses it.
  boot.kernelParams = [
    "nohibernate"
    "rtc_cmos.use_acpi_alarm=1"
  ];

  secureBoot.enable = true;

  # SMART monitoring on the NVMe.
  services.smartd.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # TEMP: expose only plain suspend to systemd. This also rejects manual
  # `systemctl hibernate`, hybrid-sleep, and suspend-then-hibernate requests.
  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
    SuspendState = "mem";
  };

  # nixos-hardware's framework module enables TLP; we use tuned instead.
  services.tlp.enable = false;

  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PermitRootLogin = "no";
  #     PasswordAuthentication = true;
  #   };
  # };
  #
  # networking.firewall.allowedTCPPorts = [ 22 ];
  #
  # users.users.tempuser = {
  #   isNormalUser = true;
  #   hashedPassword = "$6$YOqBXfzKJjUAj..T$VpdzQkuP.2RKiNRfmzmall4MD7xXhhEEdF7BcFB50iXYjEer8NZ4RAKpSoQLV0m9uUuX1Ccu.eu2MwPdWVtro1";
  # };
}
