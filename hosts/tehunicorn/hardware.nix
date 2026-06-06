# Framework 13 AMD Ryzen 7 7840U (Phoenix) — Radeon 780M.
# Most of the model-specific bits come from nixos-hardware's framework-13-7040-amd
# module, imported via the flake. This file holds anything that module doesn't cover
# and host-local quirks.
{ lib, pkgs, ... }:

{
  # Kernel modules needed to unlock LUKS + mount BTRFS at boot.
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
    "dm_mod"
    "dm_crypt"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];

  # Latest stable kernel for newer Framework/AMD support.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # AMD GPU OpenGL + Vulkan.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva
      libvdpau-va-gl
    ];
  };

  environment.variables = {
    VDPAU_DRIVER = "radeonsi";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Framework laptop firmware updates.
  services.fwupd.enable = true;
}
