# Host-agnostic hardware bits. Host-specific kernel modules / GPU live in
# hosts/<name>/hardware.nix.
{ pkgs, ... }:

{
  # Fingerprint reader (Framework uses a Goodix sensor; nixos-hardware enables it).
  services.fprintd.enable = true;

  # YubiKey: FIDO/U2F only (web 2FA + pam_u2f for sudo). No smartcard / PIV /
  # GPG-on-card use, so pcscd + gpgSmartcards are intentionally off.

  # Power profiles. power-profiles-daemon is Framework's recommended choice for
  # the AMD 7040 (the EC cooperates with PPD; FW explicitly advises against TLP).
  # PPD drives the EPP via the amd-pstate-epp driver — see amd_pstate=active in
  # boot.nix — and natively provides net.hadess.PowerProfiles for waybar's
  # pp-daemon module + GTK indicators.
  services.power-profiles-daemon.enable = true;

  # ACPI events (lid, power button, etc).
  services.acpid.enable = true;

  # Disks: TRIM weekly, udisks for thunar-volman auto-mount, upower for battery.
  services.fstrim.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;

  # SMART monitoring is enabled per-host (services.smartd.enable in hosts/tehunicorn).

  # Framework expansion bay = USB4/Thunderbolt; bolt manages authorization.
  services.hardware.bolt.enable = true;

  # Ambient light + accelerometer (auto-brightness; laptop screen rotation).
  hardware.sensor.iio.enable = true;

  # Allow flashing/inspecting YubiKey OTP as user.
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
}
