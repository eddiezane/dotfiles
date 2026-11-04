import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Column {
    id: root
    width: parent.width
    spacing: 8
    Repeater {
        model: [
            { title: "Output", node: Pipewire.defaultAudioSink, sink: true },
            { title: "Input", node: Pipewire.defaultAudioSource, sink: false }
        ]
        Column {
            id: section
            required property var modelData
            width: root.width
            spacing: 6
            Text {
                text: section.modelData.title
                color: Theme.text
                font { family: Theme.font; pixelSize: 13; bold: true }
            }
            RowLayout {
                width: parent.width
                Button {
                    text: section.modelData.node?.audio?.muted ? "Unmute" : "Mute"
                    enabled: !!section.modelData.node?.audio
                    onClicked: section.modelData.node.audio.muted = !section.modelData.node.audio.muted
                }
                Slider {
                    Layout.fillWidth: true
                    from: 0; to: 1
                    value: section.modelData.node?.audio?.volume ?? 0
                    enabled: !!section.modelData.node?.audio
                    onMoved: section.modelData.node.audio.volume = value
                }
            }
            Repeater {
                model: Pipewire.nodes
                Button {
                    required property var modelData
                    readonly property bool selected: modelData === section.modelData.node
                    visible: !modelData.isStream && !!modelData.audio && modelData.isSink === section.modelData.sink
                    width: parent.width
                    height: visible ? implicitHeight : 0
                    text: (selected ? "✓ " : "") + (modelData.description || modelData.name)
                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        elide: Text.ElideRight
                        font { family: Theme.font; pixelSize: 12 }
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (section.modelData.sink) Pipewire.preferredDefaultAudioSink = modelData;
                        else Pipewire.preferredDefaultAudioSource = modelData;
                    }
                }
            }
        }
    }
}
