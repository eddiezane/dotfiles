# TEMP hibernate/TTM debugging knobs — laptop-only. Turning transient lockups
# into panic→reboot helps root-cause the laptop's bugs but would wrongly reboot
# a server under load, so they're scoped to this host rather than the shared
# boot module. Delete once kernel-ttm-oops-chrome / hibernate-resume-crash are fixed.
{ ... }:

{
  boot.kernelParams = [
    "rtc_cmos.use_acpi_alarm=1"  # reliable wake from suspend
    # TEMP hibernate-hang capture: keep the console alive through the
    # suspend/hibernate transition so the last kernel message before a
    # freeze-phase hang is emitted rather than swallowed. See ~/hib-trace.sh +
    # pm_trace. Tracks the write-side hibernate hang first seen 2026-06-02.
    "no_console_suspend"
  ];

  # TEMP hibernate-hang capture: turn an oops into a clean panic→reboot so it
  # lands in pstore (efi-pstore is active on this Framework; systemd-pstore
  # archives to /var/lib/systemd/pstore) instead of leaving a half-dead machine.
  # NOTE: a *silent* freeze-phase hang (no oops) won't be caught by software
  # watchdogs — those threads are frozen during hibernate. Use pm_trace
  # (~/hib-trace.sh) for that class; it survives a hard power-off via the RTC.
  boot.kernel.sysctl."kernel.panic_on_oops" = 1;
  boot.kernel.sysctl."kernel.panic" = 10; # auto-reboot 10s after panic

  # TEMP TTM-cascade capture. The clean `BUG` form of kernel-ttm-oops-chrome
  # already dumps fine via panic_on_oops above. But the *other* face of the same
  # bug is a soft-lockup / RCU-stall cascade (kworker + Hyprland wedged in
  # native_queued_spin_lock_slowpath on the TTM lock) that hangs WITHOUT a clean
  # oops, so it never triggers a kmsg_dump. Convert those hangs into panics too:
  boot.kernel.sysctl."kernel.softlockup_panic" = 1; # soft lockup → panic → dump
  boot.kernel.sysctl."kernel.hung_task_panic" = 1;  # hung task → panic → dump

  # Enable all SysRq functions so a hung system can still be recovered via
  # REISUB. NixOS default is 16 (sync only); 1 = full enable. On Framework 13
  # the SysRq key is PrtSc (Alt+PrtSc+<letter>).
  # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
  boot.kernel.sysctl."kernel.sysrq" = 1;
}
