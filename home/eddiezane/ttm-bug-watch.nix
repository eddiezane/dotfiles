# TEMP kernel-TTM-bug watcher — companion to the ttm-bulk-pos-uaf-detect kernel
# patch (hosts/tehunicorn/hibernate-debug.nix). Tails the kernel journal and
# fires a critical desktop notification (swaync) when either signal appears:
#   - "stale bulk pos endpoint"  → the detector caught the UAF live; the full
#     freeing call stack is in dmesg — grab it for the upstream report.
#   - "non-zero when fini"       → hyprlock VM-fini accounting leak; perfectly
#     correlated precursor, means the boot is suspect.
# Delete this module together with the kernel patch once the bug is fixed.
{ pkgs, ... }:

let
  ttm-bug-watch = pkgs.writeShellScript "ttm-bug-watch" ''
    ${pkgs.systemd}/bin/journalctl -kf -n 0 -o cat \
        --grep 'stale bulk pos endpoint|non-zero when fini' |
      while IFS= read -r line; do
        case "$line" in
          *"stale bulk pos endpoint"*)
            summary="TTM bug CAUGHT — save the trace!"
            body="Detector fired; machine self-healed. Grab the stack now:
    journalctl -kb -g 'stale bulk pos' -o short-monotonic

    $line"
            ;;
          *)
            summary="TTM: VM fini stats leak"
            body="Benign on the fix kernel (known second symptom, stats accounting only).
    On a kernel WITHOUT the membership fix this means the boot is poisoned — reboot.

    $line"
            ;;
        esac
        ${pkgs.libnotify}/bin/notify-send --urgency=critical \
          --app-name="ttm-bug-watch" "$summary" "$body"
      done
  '';
in
{
  systemd.user.services.ttm-bug-watch = {
    Unit = {
      Description = "Notify on kernel TTM bulk-move bug signals in the journal";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${ttm-bug-watch}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
