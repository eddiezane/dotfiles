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
    # Cap the boot menu at 10 entries. Pairs with `nh clean --keep 5`
    # (modules/system/nix-tools.nix): the menu only reconciles to surviving
    # generations on a rebuild, so this is the hard ceiling regardless of GC.
    boot.loader.systemd-boot.configurationLimit = 10;
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

    # QEMU binfmt emulation so docker buildx (and nix) can cross-build/run
    # aarch64 binaries on these x86_64 hosts. Persistent across reboots, so
    # `docker buildx inspect` advertises linux/arm64 without the runtime
    # `tonistiigi/binfmt` trick. Still need a docker-container driver builder:
    #   docker buildx create --name multiarch --driver docker-container --use
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    # Register with the F ("fix binary") flag via a static emulator. Without it
    # the kernel resolves the /run/binfmt interpreter path at exec time inside
    # the caller's mount namespace — which fails inside the BuildKit container
    # (no /nix/store there), so buildx never sees arm64. F loads the emulator
    # into memory at registration, so emulation works across namespaces.
    boot.binfmt.preferStaticEmulators = true;

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
