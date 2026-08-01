# Framework Laptop 13, 12th-gen Intel Core i7-1260P (Alder Lake), headless use.
{ ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # Load Intel CPU microcode updates early during boot.
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Keep the iGPU driver available for the local console and future media
  # workloads even though normal administration is over Tailscale. The
  # 12th-gen nixos-hardware profile supplies the matching Intel media stack.
  hardware.graphics.enable = true;
}
