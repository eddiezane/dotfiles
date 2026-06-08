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
    ethtool         # NIC diagnostics / Wake-on-LAN state (`ethtool <if>`)
    macchanger
    socat
    traceroute
    whois
    wol             # send WoL magic packets (`wol -i <bcast> <mac>`); C, no perl

    # Hardware / firmware
    acpi
    powertop
    fwupd

    # Dev runtimes available system-wide; languages best installed per-project.
    gcc
    gnumake
    pkg-config
  ];
}
