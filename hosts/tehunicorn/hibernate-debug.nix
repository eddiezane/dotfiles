# RETIRED 2026-08-11 — do not import as-is. The bulk_tracked membership patch
# hit its own double-add WARN on 7.1.7 and a scanline freeze followed after the
# next hibernate cycle, disproving the earlier "crash-proof" assessment.
#
# TEMP hibernate/TTM debugging knobs — laptop-only. Turning transient lockups
# into panic→reboot helps root-cause the laptop's bugs but would wrongly reboot
# a server under load, so they're scoped to this host rather than the shared
# boot module. Delete once kernel-ttm-oops-chrome / hibernate-resume-crash are fixed.
{ pkgs, lib, ... }:

{
  # TEMP upstream-fix validation rig: extra boot entry "ttm-series-test" running
  # mainline 7.2-rc + ONLY Thomas Hellström's "drm/ttm: Represent LRU bulk moves
  # as nested sublists" v2 (patchwork series 170311) — no detector, no membership
  # fix (the redesign removes the pos->first/last cache the detector checks, so
  # it cannot stack). Purpose: run our deterministic hibernate trigger against
  # the proposed upstream fix and report to drm/amd#5387. Success = no TTM list
  # corruption / oops signatures; pstore+panic_on_oops capture net (below)
  # applies to this entry too. Pick it in the systemd-boot menu; default boot
  # stays on the patched daily-driver kernel. Delete when #5387 is resolved.
  # RETIRED 2026-07-27 (series tested 2/2 clean, reported to drm/amd#5387 note
  # 3586002). Uncomment to re-test a future revision — re-verify the patch
  # applies to whatever linuxPackages_testing has moved to first.
  #   specialisation.ttm-series-test.configuration = {
  #     boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing;
  #     boot.kernelPatches = lib.mkForce [{
  #       name = "ttm-nested-sublists-v2";
  #       patch = ./ttm-nested-sublists-v2.patch;
  #     }];
  #   };
  # TEMP kernel-ttm-oops detector: WARN + stack trace + self-heal when a
  # ttm_resource is freed (or orphaned via set_bulk_move) while still cached as
  # a bulk-move range endpoint — the exact fatal condition behind the 6
  # post-resume TTM lockups (see ~/Codez/amdgpu-ttm-bug-report/INVESTIGATION.md).
  # Instead of a delayed panic we get the culprit's freeing call stack in dmesg
  # ("stale bulk pos endpoint") and the machine keeps running. Grep for it after
  # any resume. NOTE: costs a full kernel rebuild (~30-60 min, not cached).
  # Drop the patch (and this comment) once the bug is fixed upstream.
  # Detector (canary) + candidate fix for the TTM bulk-move UAF (drm/amd#5387,
  # root-caused 2026-07-23): membership tracked explicitly (res->bulk_tracked)
  # instead of recomputing evictability at del time. Detector should stay
  # permanently silent; if it ever WARNs the fix is incomplete. Order matters
  # (fix applies on top of detector). Verified to apply against 7.1.5.
  boot.kernelPatches = [
    {
      name = "ttm-bulk-pos-uaf-detect";
      patch = ./ttm-bulk-pos-uaf-detect.patch;
    }
    {
      name = "ttm-bulk-membership-fix";
      patch = ./ttm-bulk-membership-fix.patch;
    }
  ];

  boot.kernelParams = [
    "rtc_cmos.use_acpi_alarm=1"  # reliable wake from suspend
    # TEMP hibernate-hang capture: keep the console alive through the
    # suspend/hibernate transition so the last kernel message before a
    # freeze-phase hang is emitted rather than swallowed. See ~/hib-trace.sh +
    # pm_trace. Tracks the write-side hibernate hang first seen 2026-06-02.
    "no_console_suspend"
    # TEMP kernel-ttm-oops capture, NOT YET ENABLED: SLUB allocator debugging to
    # catch the ttm_resource use-after-free red-handed. F=consistency checks,
    # Z=red zones, P=free-poisoning, U=alloc/free stack traces — when the freed
    # resource still linked in a bulk-move range is touched, the report names
    # the exact call stack that freed it. Costs a few % CPU on alloc-heavy
    # loads plus some RAM. Uncomment, `nh os boot`, reboot to arm.
    # See ~/Codez/amdgpu-ttm-bug-report/INVESTIGATION.md.
    # "slub_debug=FZPU"
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
