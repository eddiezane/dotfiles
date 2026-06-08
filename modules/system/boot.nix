# Bootloader. systemd-boot for first install (no SB keys yet), then lanzaboote
# once `secureBoot.enable = true` flips on the host. See INSTALL.md "Secure
# Boot" for the one-time enrollment dance.
{ pkgs, lib, config, ... }:

let
  cfg = config.secureBoot;
in {
  options.secureBoot.enable = lib.mkEnableOption "Secure Boot via lanzaboote";

  config = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 3;

    # systemd-boot direct (no signing) OR lanzaboote (signed). Never both.
    boot.loader.systemd-boot.enable = !cfg.enable;
    boot.loader.systemd-boot.configurationLimit = 20;
    # Pin the boot-menu console resolution. The NixOS default is "keep",
    # which preserves whatever mode the firmware/EFI var last had — that
    # drifts (a stray `r` keypress in the menu, or firmware updates, persist
    # a low GOP mode into LoaderConfigConsoleMode, making the menu text huge).
    # "max" = highest available mode (native panel res → small, tight text).
    boot.loader.systemd-boot.consoleMode = "auto";

    boot.lanzaboote = lib.mkIf cfg.enable {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    environment.systemPackages = with pkgs; [ sbctl ];

    # Systemd-in-initrd: cleaner LUKS prompting, prerequisite for lanzaboote.
    boot.initrd.systemd.enable = true;

    boot.kernelParams = [
      "quiet"
      "loglevel=3"
      "udev.log_level=3"
      # proper AMD P-state driver, better perf/W (applies to all our AMD hosts).
      "amd_pstate=active"
    ];
    boot.consoleLogLevel = 3;

    powerManagement.enable = true;

    # /tmp on tmpfs: cleared every boot, no stale cruft, fast. Defaults to
    # 50% of RAM. For big artifacts that won't fit in RAM, set TMPDIR=/var/tmp
    # (on-disk btrfs) for that command.
    boot.tmp.useTmpfs = true;

    # Compressed in-memory swap, separate from hibernation swap.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };
  };
}
