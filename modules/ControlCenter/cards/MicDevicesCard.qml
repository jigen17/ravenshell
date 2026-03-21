import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 10

        RavenText { text: "Mic Device" }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: ColorService.colorPalette.backgroundSecondary_300
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Ui.tokens.spacing.sm
            model: AudioService.sources

            delegate: Item {
                required property var modelData
                width: listView.width
                height: 50

                readonly property bool isActive: modelData.id === AudioService.source.id

                Rectangle {
                    anchors.fill: parent
                    color: parent.isActive
                           ? ColorService.colorPalette.accentTertiary
                           : ColorService.colorPalette.backgroundSecondary_300
                    radius: 12
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                ColumnLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 0
                    RavenText { text: modelData.description }
                    RavenText {
                        fontSize: 10
                        text: modelData.nickname
                        opacity: 0.8
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: AudioService.setAudioSource(modelData)
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
