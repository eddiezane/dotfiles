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

  # UDS DHCP/PXE provisioning on the dedicated USB Ethernet adapter only.
  # The enrollment UI remains loopback-only; do not trust the whole interface.
  networking.firewall.interfaces.enp195s0f3u1 = {
    allowedUDPPorts = [ 67 69 ]; # DHCP server and TFTP bootloaders.
    allowedTCPPorts = [ 8080 ]; # Boot assets and read-only status.
  };

  services.logind.settings.Login = {
    HandlePowerKey = "lock";
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
  #   hashedPassword = "$6$Hr4QHeYEzFO5P2W1$bsmowRS3NIyxrrZpe9St.7D.sfqcvMAHbSi9C6PriDN0.zALojAfIw/LcjbFRJIUw32sPR7JYIAh/VSjWe66R0";
  # };
}
