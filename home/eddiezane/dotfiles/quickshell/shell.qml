//@ pragma IconTheme Adwaita
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool barsVisible: true
    Status { id: systemStatus }
    IpcHandler {
        target: "bar"
        function toggle(): void { root.barsVisible = !root.barsVisible; }
    }
    Variants {
        model: Quickshell.screens
        Bar {
            required property var modelData
            screen: modelData
            visible: root.barsVisible
            status: systemStatus
        }
    }
}
