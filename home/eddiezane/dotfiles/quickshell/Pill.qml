import QtQuick

Rectangle {
    id: root
    property string text: ""
    property string tooltip: ""
    property color foreground: Theme.crust
    property int padding: 10
    signal clicked(var button)
    signal scrolled(int direction)
    implicitWidth: label.implicitWidth + padding * 2
    implicitHeight: 22
    radius: 4
    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.foreground
        font.family: Theme.font
        font.pixelSize: 13
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => root.clicked(event.button)
        onWheel: event => {
            if (event.angleDelta.y !== 0) root.scrolled(event.angleDelta.y > 0 ? 1 : -1);
        }
    }
    HoverTip {
        anchor.item: root
        active: mouse.containsMouse
        text: root.tooltip
    }
}
