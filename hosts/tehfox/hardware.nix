# tehfox hardware — Ryzen 9 5900X + RTX 3080 (GA102). No iGPU, so the NVIDIA
# card is the only GPU (no amdgpu, unlike tehunicorn) and it's configured for
# headless CUDA compute — no display ever attached.
{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # NVIDIA for CUDA. Keep the default kernel (not linuxPackages_latest) so the
  # out-of-tree module always has a matching build — headless gains nothing from
  # a newer kernel and loses if the driver lags.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  hardware.nvidia = {
    open = true;                # recommended/default on Ampere+
    modesetting.enable = true;
    nvidiaSettings = false;     # GTK GUI — pointless headless
    nvidiaPersistenced = true;  # avoid GPU re-init latency between idle CUDA jobs
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # GPU passthrough into docker/podman (`--device nvidia.com/gpu=all`).
  hardware.nvidia-container-toolkit.enable = true;

  # GPU monitoring TUI. nvidia-only variant — `.full`/`nvtop` also pull AMD+Intel.
  environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];

  services.fstrim.enable = true;
  services.smartd.enable = true;
}
