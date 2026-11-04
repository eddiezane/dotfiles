import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

MenuItem {
    id: control
    property var entry: null
    text: entry?.text ?? subMenu?.title ?? ""
    enabled: entry?.enabled ?? subMenu?.enabled ?? true
    icon.source: entry?.icon ?? subMenu?.icon.source ?? ""
    checkable: entry !== null && entry.buttonType !== QsMenuButtonType.None
    checked: entry !== null && entry.checkState !== Qt.Unchecked
    onTriggered: if (entry) entry.triggered()

    implicitWidth: Math.max(240, Math.min(520, label.implicitWidth + 88))
    implicitHeight: 30
    leftPadding: 28
    rightPadding: 28
    topPadding: 5
    bottomPadding: 5
    opacity: enabled ? 1 : 0.45
    background: Rectangle {
        radius: 4
        color: control.highlighted ? Theme.red : "transparent"
    }
    contentItem: RowLayout {
        spacing: 8
        Image {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            source: control.icon.source
            sourceSize: Qt.size(16, 16)
        }
        Text {
            id: label
            Layout.fillWidth: true
            text: control.text.replace(/&(.)/g, "$1")
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: control.highlighted ? Theme.crust : Theme.text
            font { family: Theme.font; pixelSize: 13 }
        }
    }
    indicator: Text {
        x: 7
        anchors.verticalCenter: parent.verticalCenter
        text: !control.checked ? "" : control.entry?.buttonType === QsMenuButtonType.RadioButton ? "●" : "✓"
        color: control.highlighted ? Theme.crust : Theme.red
        font.pixelSize: 13
    }
    arrow: Text {
        x: control.width - width - 10
        anchors.verticalCenter: parent.verticalCenter
        visible: control.subMenu !== null
        text: "›"
        color: control.highlighted ? Theme.crust : Theme.text
        font.pixelSize: 18
    }
}
