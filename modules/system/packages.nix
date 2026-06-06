# System-wide packages — tools that should be available to root, scripts,
# and recovery shells (tty rescue, single-user mode, before login). User-
# runnable tools live at home-level (home/eddiezane/*.nix).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core CLI (tty / rescue / scripts)
    bc
    curl
    fd
    fzf
    gdu
    git
    inxi
    lshw
    man-pages
    nmap
    pciutils
    tmux
    unzip
    usbutils
    vim
    wget
    zip

    # Filesystem / disk
    btrfs-progs
    compsize        # BTRFS compression-ratio inspector
    dosfstools
    e2fsprogs
    gptfdisk
    parted
    smartmontools
    cryptsetup

    # Network tools
    dig
    bind
    macchanger
    socat
    traceroute
    whois

    # Hardware / firmware
    acpi
    powertop
    fwupd
    framework-tool

    # Dev runtimes available system-wide; languages best installed per-project.
    gcc
    gnumake
    pkg-config
  ];
}
