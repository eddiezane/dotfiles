{ pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd"; # iwd over the default wpa_supplicant
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  # NixOS applies this quirk to every driver when NetworkManager uses iwd,
  # forcing iwd to use the kernel-created interface. That races when wlan0
  # arrives late. Restore iwd's upstream behavior so it owns the
  # wireless interface lifecycle and can create the interface itself. The
  # INI generator renders null as a driver pattern that matches no driver.
  networking.wireless.iwd.settings.DriverQuirks.DefaultInterface = null;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    # Tailscale interface always trusted. virbr0 trusted so libvirt VMs can
    # reach dev services running on the host.
    trustedInterfaces = [
      "tailscale0"
      "virbr0"
    ];
  };

  # systemd-resolved for DNS (NetworkManager will plug into it).
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      FallbackDNS = [
        "1.1.1.1"
        "9.9.9.9"
      ];
    };
  };
}
