import QtQuick
import QtQuick.Controls
import Quickshell

Menu {
    id: root
    property var menuHandle: null
    property bool loaded: false
    onAboutToShow: loaded = true
    onClosed: loaded = false
    // Load recursively through a component to allow arbitrary submenu depth.
    readonly property var submenuComponent: Qt.createComponent("TrayMenu.qml")
    popupType: Popup.Window
    cascade: true
    overlap: 3
    padding: 6
    margins: 6
    implicitWidth: {
        let desired = 252;
        for (let i = 0; i < count; i++)
            desired = Math.max(desired, (itemAt(i)?.implicitWidth ?? 0) + leftPadding + rightPadding);
        return desired;
    }
    font { family: Theme.font; pixelSize: 13 }
    delegate: TrayMenuItem { }
    enter: Transition { }
    exit: Transition { }
    background: Rectangle {
        color: Theme.background
        radius: 6
        border.color: Theme.overlay
        border.width: 1
    }
    QsMenuOpener { id: opener; menu: root.loaded ? root.menuHandle : null }
    Component { id: itemComponent; TrayMenuItem { } }
    Component {
        id: separatorComponent
        MenuSeparator {
            padding: 5
            contentItem: Rectangle { implicitWidth: 240; implicitHeight: 1; color: Theme.surface }
        }
    }
    Instantiator {
        model: opener.children
        delegate: QtObject {
            id: row
            required property var modelData
            required property int index
            property var rendered: null
            property bool submenu: false

            function removeEntry() {
                if (!rendered) return;
                if (submenu) root.removeMenu(rendered);
                else root.removeItem(rendered);
                rendered.destroy();
                rendered = null;
            }
            function createEntry() {
                submenu = !modelData.isSeparator && modelData.hasChildren;
                if (submenu) {
                    rendered = root.submenuComponent.createObject(root, {
                        menuHandle: modelData,
                        title: Qt.binding(() => row.modelData.text),
                        enabled: Qt.binding(() => row.modelData.enabled)
                    });
                    if (!rendered) { console.warn("Could not create tray submenu:", root.submenuComponent.errorString()); return; }
                    rendered.icon.source = Qt.binding(() => row.modelData.icon);
                    root.insertMenu(index, rendered);
                } else {
                    rendered = modelData.isSeparator ? separatorComponent.createObject(root.contentItem)
                        : itemComponent.createObject(root.contentItem, {entry: modelData});
                    root.insertItem(index, rendered);
                }
            }
            property Connections updates: Connections {
                target: row.modelData
                function onHasChildrenChanged() { row.removeEntry(); row.createEntry(); }
                function onIsSeparatorChanged() { row.removeEntry(); row.createEntry(); }
            }
        }
        onObjectAdded: (index, object) => object.createEntry()
        onObjectRemoved: (index, object) => object.removeEntry()
    }
}
