import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    property var stats: ({})
    property bool dnd: false
    property int notificationCount: 0
    property double inhibitUntil: 0
    property double now: Date.now()
    readonly property bool inhibited: inhibitUntil > now
    readonly property string inhibitTooltip: !inhibited ? "Prevent idle locking (default: 1 hour)" : inhibitUntil === Infinity ? "Idle locking inhibited indefinitely" : "Idle locking inhibited for " + Math.ceil((inhibitUntil - now) / 60000) + " more minutes"
    function inhibit(minutes) { inhibitUntil = minutes === 0 ? Infinity : Date.now() + minutes * 60000; }
    function run(args) { Quickshell.execDetached(args); }
    Process {
        id: statsProcess
        command: ["python3", Quickshell.shellPath("stats.py")]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try { root.stats = JSON.parse(data); }
                catch (e) { console.warn("Invalid stats:", e); }
            }
        }
        onExited: restartStats.start()
    }
    Timer { id: restartStats; interval: 5000; onTriggered: statsProcess.running = true }
    // SwayNC remains the notification server; subscribe to its status stream.
    Process {
        id: notificationProcess
        command: ["swaync-client", "--subscribe"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    const status = JSON.parse(data);
                    root.dnd = status.dnd;
                    root.notificationCount = status.count;
                } catch (e) { console.warn("Invalid SwayNC status:", e); }
            }
        }
        onExited: restartNotifications.start()
    }
    Timer { id: restartNotifications; interval: 5000; onTriggered: notificationProcess.running = true }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = Date.now() }
}
