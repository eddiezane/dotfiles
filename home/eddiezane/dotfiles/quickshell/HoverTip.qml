import QtQuick
import Quickshell

PopupWindow {
    id: root
    property string text: ""
    property bool active: false
    property bool ready: false
    anchor.edges: Edges.Top
    anchor.gravity: Edges.Top
    anchor.margins.top: -8
    implicitWidth: Math.ceil(Math.min(600, measurement.implicitWidth + 20))
    implicitHeight: label.implicitHeight + 16
    color: "transparent"
    visible: active && ready && text !== ""
    onActiveChanged: {
        ready = false;
        if (active) delay.restart();
        else delay.stop();
    }
    Timer { id: delay; interval: 500; onTriggered: root.ready = true }
    // Measure without a width constraint so wrapped text cannot shrink the popup.
    Text {
        id: measurement
        visible: false
        text: root.text
        textFormat: Text.PlainText
        font: label.font
        wrapMode: Text.NoWrap
    }
    Rectangle {
        anchors.fill: parent
        radius: 4
        color: Theme.background
        border.color: Theme.overlay
        Text {
            id: label
            x: 10; y: 8
            width: root.width - 20
            text: root.text
            textFormat: Text.PlainText
            color: Theme.text
            font { family: Theme.font; pixelSize: 13 }
            wrapMode: Text.Wrap
        }
    }
}
