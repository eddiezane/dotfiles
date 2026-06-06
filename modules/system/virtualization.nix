{ pkgs, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        # qemu runs as the `qemu` user, not root (modern default; user is in
        # libvirtd group so VMs still launch).
        runAsRoot = false;
        swtpm.enable = true;
      };
    };

    podman = {
      enable = true;
      # Don't override the docker socket; user runs both.
      dockerCompat = false;
    };

    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  users.users.eddiezane.extraGroups = [ "docker" "libvirtd" "kvm" ];

  environment.systemPackages = with pkgs; [
    distrobox
    docker-credential-helpers
    qemu_kvm
    swtpm
  ];
}
