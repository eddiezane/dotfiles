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
      # AMD Phoenix (Ryzen 7040 series) ergonomics:
      "amd_pstate=active"          # proper P-state driver, better perf/W
      "rtc_cmos.use_acpi_alarm=1"  # reliable wake from suspend
      # TEMP hibernate-hang capture (remove once root-caused). Keeps the
      # console alive through the suspend/hibernate transition so the last
      # kernel message before a freeze-phase hang is emitted rather than
      # swallowed. See ~/hib-trace.sh + the pm_trace technique for naming
      # the offending device. Tracking the write-side hibernate hang first
      # observed 2026-06-02 (distinct from the resume-side compositor wedge).
      "no_console_suspend"
    ];
    boot.consoleLogLevel = 3;

    # TEMP hibernate-hang capture (remove once root-caused): turn an oops into
    # a clean panic→reboot so it lands in pstore (efi-pstore is active on this
    # Framework; systemd-pstore archives to /var/lib/systemd/pstore) instead of
    # leaving a half-dead machine. NOTE: a *silent* freeze-phase hang (no oops)
    # won't be caught by software watchdogs — those threads are frozen during
    # hibernate. Use pm_trace (~/hib-trace.sh) for that class; it survives a
    # hard power-off via the RTC and names the stuck device on next boot.
    boot.kernel.sysctl."kernel.panic_on_oops" = 1;
    boot.kernel.sysctl."kernel.panic" = 10; # auto-reboot 10s after panic

    # TEMP TTM-cascade capture (remove once root-caused). The clean `BUG`
    # form of [[kernel-ttm-oops-chrome]] already dumps fine via
    # panic_on_oops above — efi-pstore caught the full call chain on the
    # 2026-06-05 occurrence (4th). But the *other* face of the same bug is a
    # soft-lockup / RCU-stall cascade (kworker + Hyprland wedged in
    # native_queued_spin_lock_slowpath on the TTM lock) that hangs WITHOUT a
    # clean oops, so it never triggers a kmsg_dump and we lose the trace.
    # Convert those hangs into panics so they land in efi-pstore too:
    boot.kernel.sysctl."kernel.softlockup_panic" = 1; # soft lockup → panic → dump
    boot.kernel.sysctl."kernel.hung_task_panic" = 1;  # hung task → panic → dump

    # Enable all SysRq functions so a hung system can still be recovered
    # via REISUB (Raw → tErminate → kIll → Sync → Unmount → reBoot) or
    # related sequences. NixOS default is 16 (sync only); 1 = full enable.
    # On Framework 13 the SysRq key is PrtSc (Alt+PrtSc+<letter>).
    # Particularly relevant for [[kernel-ttm-oops-chrome]] recurrences:
    # the kernel hangs in TTM after a soft lockup cascade, so reboot/sync/
    # remount-RO via SysRq is the only graceful exit short of a hard cycle.
    # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
    boot.kernel.sysctl."kernel.sysrq" = 1;

    powerManagement.enable = true;

    # Compressed in-memory swap, separate from hibernation swap.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };
  };
}
