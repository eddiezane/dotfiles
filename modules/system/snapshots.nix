# Snapper: BTRFS snapshot management.
#
# Opt-in — the import in hosts/common.nix is commented out by default. The
# disko layout intentionally omits a separate `@snapshots` subvol so snapper
# can own `.snapshots` inside @ and @home directly.
#
# Two configs ("root" for /, "home" for /home). Each gets:
#   - A `.snapshots` subvolume inside its managed subvol (created on activation).
#   - A timeline timer that takes periodic read-only snapshots and prunes them
#     by an hourly/daily/weekly/monthly/yearly retention policy.
#
# Why two configs (not one):
#   - Root and home churn at different rates; you want different retention.
#   - You can roll back /home independently without touching the system.
#   - NixOS already handles system *generation* rollback via systemd-boot's
#     boot menu, so snapper-on-root is more about "I deleted a file I shouldn't
#     have" than disaster recovery.
#
# How to use:
#   sudo snapper -c root list             # list snapshots for /
#   sudo snapper -c root create -d 'pre-experiment'  # ad-hoc named snapshot
#   sudo snapper -c home undochange 12..14 /path/to/file   # restore file
#   sudo snapper -c root rollback 42      # roll the whole subvol back
#
# `pre-rebuild` snapshots are aliased into zsh — see home/eddiezane/shell.nix.
{ ... }:

{
  services.snapper = {
    # Run cleanup more frequently than the default (daily) — we keep retention tight.
    cleanupInterval = "1d";

    # Snapshots are taken hourly; runner persists across reboots.
    persistentTimer = true;

    configs = {
      root = {
        SUBVOLUME = "/";
        ALLOW_USERS = [ "eddiezane" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        # Retention: 12 hourly, 7 daily, 4 weekly, 0 monthly, 0 yearly.
        TIMELINE_MIN_AGE = "1800";
        TIMELINE_LIMIT_HOURLY = "12";
        TIMELINE_LIMIT_DAILY = "7";
        TIMELINE_LIMIT_WEEKLY = "4";
        TIMELINE_LIMIT_MONTHLY = "0";
        TIMELINE_LIMIT_YEARLY = "0";
        # Don't snapshot /nix (it's its own subvol so it's already excluded).
      };

      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "eddiezane" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        # Home gets a longer tail since recovering "that file I had on Tuesday"
        # is the primary use case.
        TIMELINE_MIN_AGE = "1800";
        TIMELINE_LIMIT_HOURLY = "24";
        TIMELINE_LIMIT_DAILY = "14";
        TIMELINE_LIMIT_WEEKLY = "8";
        TIMELINE_LIMIT_MONTHLY = "6";
        TIMELINE_LIMIT_YEARLY = "0";
      };
    };
  };
}
