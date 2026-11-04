# Quickshell bar

The desktop bar, using the Quickshell version pinned by nixpkgs. The Home Manager
module starts it with the UWSM graphical session.

The bar appears at the bottom of each monitor. Workspaces are local to that
monitor; scratch/equal/minus special workspaces stay hidden. Colors and the
13px SauceCodePro Nerd Font follow the existing Macchiato styling.

## Controls

| Item | Action |
| --- | --- |
| Workspace | Click to switch |
| Notifications | Click for SwayNC; right-click toggles do not disturb |
| Eye | Click to inhibit idle locking for an hour, or stop; right-click chooses 30 minutes, 1/2/4 hours, or indefinitely |
| Audio | Click for output/input volume, mute, and device selection; scroll adjusts output; middle-click mutes output; right-click opens pavucontrol |
| Network | Shows Wi-Fi/Ethernet device status; click opens Tatami Network |
| CPU | Click opens Tatami Activity |
| Brightness | Click for a slider; scroll adjusts by 5% |
| Power profile | Click to cycle through available profiles |
| Date | Click for a calendar with month navigation |
| Tray | Left/middle/right-click and scrolling are forwarded to each application |
| Super+M | Hide/show all bars |
| Super+Shift+M | Restart the Quickshell service |

Idle inhibition uses Wayland's idle-inhibit protocol. It does not
block an explicit suspend or change logind's lid policy. It expires by wall-clock
time, clears when the bar exits, and applies while a bar is visible.

Quickshell supplies native Hyprland, PipeWire, NetworkManager, UPower,
power-profile, and tray integration. SwayNC remains the notification server.
`stats.py` supplies CPU, RAM, root filesystem, temperature/fan, and backlight
readings from `/proc` and `/sys` every two seconds. The displayed temperature is
the CPU sensor; hover shows the other available readings. Hovering status pills
shows their details.

## Rebuilding

Rebuild the desktop configuration normally once the new files have been staged.
For a build that includes unstaged new files, from the repository root:

```sh
sudo nixos-rebuild switch --flake "path:$PWD#tehunicorn"
```

Logs: `journalctl --user -u quickshell -b`.
