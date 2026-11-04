import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Wayland

PanelWindow {
    id: bar
    required property var status
    readonly property var monitor: Hyprland.monitorFor(screen)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var battery: UPower.displayDevice
    readonly property string batteryIcon: {
        const charge = battery?.percentage ?? 0;
        return charge <= 0.10 ? "" : charge <= 0.25 ? "" : charge <= 0.50 ? "" : charge <= 0.75 ? "" : "";
    }
    property string openPopup: ""
    function togglePopup(name) { openPopup = openPopup === name ? "" : name; }
    function volumeText(node, icon) {
        return !node?.audio ? icon + " —" : node.audio.muted ? icon + " ×" : icon + " " + Math.round(node.audio.volume * 100) + "%";
    }
    function changeVolume(direction) {
        if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + direction * 0.05));
    }
    function cycleProfile() {
        const p = PowerProfiles.profile;
        PowerProfiles.profile = p === PowerProfile.PowerSaver ? PowerProfile.Balanced
            : p === PowerProfile.Balanced && PowerProfiles.hasPerformanceProfile ? PowerProfile.Performance : PowerProfile.PowerSaver;
    }
    anchors { left: true; right: true; bottom: true }
    implicitHeight: 26
    color: Theme.background
    WlrLayershell.namespace: "dotfiles-bar"
    onVisibleChanged: if (!visible) openPopup = ""
    PwObjectTracker { objects: [bar.sink, bar.source] }
    IdleInhibitor { window: bar; enabled: bar.status.inhibited }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 3
        color: "#8064727d"
    }
    Row {
        id: workspaces
        x: 2; y: 1
        spacing: 4
        Repeater {
            model: Hyprland.workspaces.values.slice().sort((a, b) => a.id - b.id)
            Pill {
                required property var modelData
                visible: modelData.monitor === bar.monitor && !["special:scratch", "special:equal", "special:minus"].includes(modelData.name)
                width: visible ? implicitWidth : 0
                padding: 8
                text: modelData.name
                color: modelData.urgent ? "#eb4d4b" : modelData.active ? Theme.red : Theme.surface
                foreground: modelData.active || modelData.urgent ? Theme.crust : Theme.text
                onClicked: modelData.activate()
            }
        }
    }
    // Scroll instead of overlapping workspaces on a narrow display.
    Flickable {
        id: scroller
        anchors { left: workspaces.right; leftMargin: 8; right: parent.right; rightMargin: 2; top: parent.top; topMargin: 1 }
        height: 22
        contentWidth: modules.width
        contentHeight: height
        contentX: Math.max(0, contentWidth - width)
        clip: true
        flickableDirection: Flickable.HorizontalFlick
        Row {
            id: modules
            x: Math.max(0, scroller.width - width)
            spacing: 4
            Pill {
                text: bar.status.dnd ? "󰂛" : bar.status.notificationCount > 0 ? "󱅫" : ""
                color: Theme.pink
                tooltip: bar.status.notificationCount + " notifications" + (bar.status.dnd ? " · Do not disturb" : "") + "\nLeft: notifications · Right: toggle DND"
                onClicked: button => bar.status.run(["swaync-client", button === Qt.RightButton ? "--toggle-dnd" : "--toggle-panel"])
            }
            Pill {
                id: inhibit
                text: bar.status.inhibited ? "" : ""
                color: bar.status.inhibited ? Theme.yellow : Theme.subtext
                tooltip: bar.status.inhibitTooltip + "\nLeft: toggle · Right: choose duration"
                onClicked: button => {
                    if (button === Qt.RightButton) bar.togglePopup("inhibit");
                    else if (bar.status.inhibited) bar.status.inhibitUntil = 0;
                    else bar.status.inhibit(60);
                }
            }
            Pill {
                id: audio
                text: bar.volumeText(bar.sink, "") + "  " + bar.volumeText(bar.source, "")
                color: Theme.lavender
                tooltip: (bar.sink?.description ?? "No output") + "\n" + (bar.source?.description ?? "No input") + "\nScroll: volume · Middle: mute output · Right: mixer"
                onScrolled: direction => bar.changeVolume(direction)
                onClicked: button => {
                    if (button === Qt.RightButton) bar.status.run(["pavucontrol"]);
                    else if (button === Qt.MiddleButton && bar.sink?.audio) bar.sink.audio.muted = !bar.sink.audio.muted;
                    else bar.togglePopup("audio");
                }
            }
            Pill {
                readonly property var devices: Networking.devices.values.filter(d => d.type === DeviceType.Wifi || d.type === DeviceType.Wired)
                visible: devices.length > 0
                text: devices.map(d => (d.type === DeviceType.Wifi ? "" : "󰈀") + (d.connected ? "" : " ×")).join("  ")
                color: Theme.sky
                tooltip: devices.map(d => {
                    const connection = d.networks.values.find(n => n.connected);
                    return d.name + ": " + (connection?.name ?? ConnectionState.toString(d.state));
                }).join("\n") + "\nOpen Tatami Network"
                onClicked: bar.status.run(["tatami", "launch", "tatami-network"])
            }
            Pill { text: (bar.status.stats.disk ?? "—") + "% "; color: "#c68642"; tooltip: bar.status.stats.diskTooltip ?? "Root filesystem" }
            Pill { text: (bar.status.stats.cpu ?? "—") + "% "; color: Theme.maroon; tooltip: bar.status.stats.cpuTooltip ?? "CPU"; onClicked: bar.status.run(["tatami", "launch", "tatami-activity"]) }
            Pill { text: (bar.status.stats.memory ?? "—") + "% 󰍛"; color: Theme.mauve; tooltip: bar.status.stats.memoryTooltip ?? "Memory" }
            Pill { text: (bar.status.stats.temperature ?? "—") + "°C "; color: Theme.yellow; tooltip: bar.status.stats.temperatureTooltip ?? "Temperature" }
            Pill {
                id: backlight
                visible: bar.status.stats.brightness !== null && bar.status.stats.brightness !== undefined
                text: "󰃠 " + (bar.status.stats.brightness ?? "—") + "%"
                color: Theme.overlay
                tooltip: "Brightness\nScroll: adjust · Click: slider"
                onScrolled: direction => bar.status.run(["brightnessctl", "--class=backlight", "set", direction > 0 ? "5%+" : "5%-", "--min-value=1"])
                onClicked: bar.togglePopup("brightness")
            }
            Rectangle {
                implicitWidth: powerRow.width
                implicitHeight: 22
                color: Theme.green
                radius: 4
                Row {
                    id: powerRow
                    Pill {
                        color: "transparent"
                        text: PowerProfiles.profile === PowerProfile.Performance ? "󰤇" : PowerProfiles.profile === PowerProfile.PowerSaver ? "󰴻" : ""
                        tooltip: "Power profile: " + PowerProfile.toString(PowerProfiles.profile) + "\nClick to cycle"
                        onClicked: bar.cycleProfile()
                    }
                    Rectangle { width: 1; height: 22; color: Theme.surface; visible: bar.battery?.isPresent ?? false }
                    Pill {
                        visible: bar.battery?.isPresent ?? false
                        color: UPower.onBattery && bar.battery.percentage <= 0.15 ? "#f53c3c" : "transparent"
                        text: (UPower.onBattery ? bar.batteryIcon + " " : " ") + Math.round((bar.battery?.percentage ?? 0) * 100) + "%"
                        tooltip: UPowerDeviceState.toString(bar.battery.state) + "\n" + bar.battery.changeRate.toFixed(1) + " W\n" + (UPower.onBattery ? "Remaining: " + Math.round(bar.battery.timeToEmpty / 60) : "Until full: " + Math.round(bar.battery.timeToFull / 60)) + " min"
                    }
                }
            }
            Pill { text: Qt.formatDateTime(new Date(bar.status.now), "HH:mm t"); color: Theme.peach; tooltip: Qt.formatDateTime(new Date(bar.status.now), "dddd, MMMM d yyyy") }
            Pill {
                id: date
                text: Qt.formatDateTime(new Date(bar.status.now), "yyyy-MM-dd")
                color: Theme.flamingo
                onClicked: bar.togglePopup("calendar")
            }
            Tray { }
        }
    }
    BarPopup {
        anchor.item: inhibit
        visible: bar.visible && bar.openPopup === "inhibit"
        onVisibleChanged: if (!visible && bar.openPopup === "inhibit") bar.openPopup = ""
        Repeater {
            model: [{label: "30 minutes", minutes: 30}, {label: "1 hour", minutes: 60}, {label: "2 hours", minutes: 120}, {label: "4 hours", minutes: 240}, {label: "Indefinitely", minutes: 0}]
            Button {
                required property var modelData
                width: parent.width
                text: modelData.label
                onClicked: { bar.status.inhibit(modelData.minutes); bar.openPopup = ""; }
            }
        }
        Button { width: parent.width; text: "Stop inhibiting"; onClicked: { bar.status.inhibitUntil = 0; bar.openPopup = ""; } }
    }
    BarPopup {
        anchor.item: audio
        visible: bar.visible && bar.openPopup === "audio"
        onVisibleChanged: if (!visible && bar.openPopup === "audio") bar.openPopup = ""
        AudioControls { }
    }
    BarPopup {
        anchor.item: backlight
        visible: bar.visible && bar.openPopup === "brightness"
        onVisibleChanged: if (!visible && bar.openPopup === "brightness") bar.openPopup = ""
        Slider {
            width: parent.width
            from: 1; to: 100; stepSize: 1
            value: bar.status.stats.brightness ?? 50
            onMoved: bar.status.run(["brightnessctl", "--class=backlight", "set", Math.round(value) + "%"])
        }
    }
    BarPopup {
        id: calendar
        property date month: new Date()
        anchor.item: date
        visible: bar.visible && bar.openPopup === "calendar"
        onVisibleChanged: {
            if (!visible && bar.openPopup === "calendar") bar.openPopup = "";
            if (visible) month = new Date();
        }
        RowLayout {
            width: parent.width
            Button { text: "‹"; onClicked: calendar.month = new Date(calendar.month.getFullYear(), calendar.month.getMonth() - 1, 1) }
            Label { Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; color: Theme.text; text: Qt.formatDateTime(calendar.month, "MMMM yyyy") }
            Button { text: "›"; onClicked: calendar.month = new Date(calendar.month.getFullYear(), calendar.month.getMonth() + 1, 1) }
        }
        DayOfWeekRow { width: parent.width; locale: monthGrid.locale; palette.windowText: Theme.text }
        MonthGrid {
            id: monthGrid
            width: parent.width
            month: calendar.month.getMonth()
            year: calendar.month.getFullYear()
            palette.windowText: Theme.text
            palette.highlight: Theme.red
        }
    }
}
