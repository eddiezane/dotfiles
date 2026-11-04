import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: root
    implicitWidth: icons.implicitWidth + 8
    implicitHeight: 22
    radius: 4
    color: Theme.sapphire
    visible: SystemTray.items.values.length > 0
    Row {
        id: icons
        anchors.centerIn: parent
        Repeater {
            model: SystemTray.items
            Item {
                id: entry
                required property var modelData
                width: 24
                height: 22
                Image {
                    anchors.centerIn: parent
                    width: 16; height: 16
                    source: entry.modelData.icon
                    sourceSize: Qt.size(16, 16)
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: event => {
                        if (event.button === Qt.RightButton || (event.button === Qt.LeftButton && entry.modelData.onlyMenu)) {
                            if (entry.modelData.hasMenu) menu.open();
                        } else if (event.button === Qt.MiddleButton) entry.modelData.secondaryActivate();
                        else entry.modelData.activate();
                    }
                    onWheel: event => entry.modelData.scroll(event.angleDelta.y, false)
                }
                TrayMenu {
                    id: menu
                    y: -height - 5
                    menuHandle: entry.modelData.menu
                }
                HoverTip {
                    anchor.item: entry
                    active: mouse.containsMouse && !menu.visible
                    text: entry.modelData.tooltipTitle || entry.modelData.title || entry.modelData.id
                }
            }
        }
    }
}
