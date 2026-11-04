# Framework laptop.
{ lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/desktop.nix
    ../../modules/disko/luks-btrfs.nix
    ./hardware.nix
  ];

  _module.args.diskoArgs = {
    disk = "/dev/nvme0n1";
    swapSize = "96G"; # Retained for future hibernation; also normal swap.
    espSize = "1G";
  };

  # LUKS backing device for the root filesystem and retained swapfile.
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/disk-main-luks";

  # Disable hibernation and image restore pending resolution of the hibernate
  # failures. Plain s2idle still needs the RTC alarm quirk.
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

  # nixos-hardware enables TLP; power-profiles-daemon manages power profiles.
  services.tlp.enable = false;
}
