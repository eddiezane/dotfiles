{ pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd"; # iwd over the default wpa_supplicant
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  # Don't block boot on network-online.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Fix an intermittent boot race: with the iwd backend, NixOS generates
  # /etc/iwd/main.conf with `[DriverQuirks] DefaultInterface=?*`, so iwd never
  # creates its own station interface — it only ever uses the kernel-created
  # wlan0. When the mt7921e driver is slow to register the netdev (firmware
  # load latency), iwd enumerates phy0 first, logs "No default interface for
  # wiphy 0", and then fails to start a station on the late-arriving wlan0 —
  # so iwd exposes no wifi device and NetworkManager "sees no wifi devices"
  # until a reboot. Observed 2026-06-03. Ordering iwd after the wlan0 device
  # unit makes iwd wait until the netdev exists, closing the race. Soft dep
  # (wants, not requires) so an absent/rfkilled card never blocks boot.
  systemd.services.iwd = {
    after = [ "sys-subsystem-net-devices-wlan0.device" ];
    wants = [ "sys-subsystem-net-devices-wlan0.device" ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    # Tailscale interface always trusted. virbr0 trusted so libvirt VMs can
    # reach dev services running on the host.
    trustedInterfaces = [ "tailscale0" "virbr0" ];
  };

  # systemd-resolved for DNS (NetworkManager will plug into it).
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      FallbackDNS = [ "1.1.1.1" "9.9.9.9" ];
    };
  };
}
