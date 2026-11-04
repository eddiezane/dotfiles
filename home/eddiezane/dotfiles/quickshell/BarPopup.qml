import QtQuick
import QtQuick.Controls
import Quickshell

PopupWindow {
    id: root
    default property alias contents: content.data
    anchor.edges: Edges.Top | Edges.Right
    anchor.gravity: Edges.Top | Edges.Left
    anchor.margins.top: -8
    implicitWidth: 340
    implicitHeight: content.implicitHeight + 24
    color: "transparent"
    grabFocus: true
    Pane {
        anchors.fill: parent
        padding: 0
        palette {
            window: Theme.background
            windowText: Theme.text
            text: Theme.text
            button: Theme.surface
            buttonText: Theme.text
            base: Theme.surface
            highlight: Theme.red
            highlightedText: Theme.crust
        }
        background: Rectangle { radius: 6; color: Theme.background; border.color: Theme.overlay }
        Column {
            id: content
            x: 12
            y: 12
            width: root.width - 24
            spacing: 8
        }
    }
}
