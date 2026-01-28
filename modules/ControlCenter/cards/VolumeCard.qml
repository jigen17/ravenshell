import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.assets
import qs.config
import qs.services
import qs.widgets

Rectangle {
    id: root
    color: ColorService.colorPalette.backgroundSecondary_300
    implicitHeight: Ui.tokens.spacing.md * 2 + 40
    property bool menuopen: false
    RowLayout {
        anchors {
            fill: parent
            margins: Ui.tokens.spacing.md
        }

        // Audio column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1  // Equal weight
            spacing: Ui.tokens.spacing.sm

            RowLayout {
                Layout.fillWidth: true
                spacing: Ui.tokens.spacing.sm

                ButtonIcon {
                    iconSize: 18
                    iconName: AudioService.sinkIcon
                    onClicked: AudioService.toggleSinkMute()
                }

                RavenText {
                    text: "Audio"
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                radius: 5
                value: AudioService.volume
                onMoved: AudioService.setVolume(value)
                hoverEnabled: true
                wheelEnabled: true
                showTooltip: true
                tooltipPrefix: `Audio volume: ${Math.round(value * 100)}%`
            }
        }

        // Mic column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1  // Equal weight
            spacing: Ui.tokens.spacing.sm

            RowLayout {
                Layout.fillWidth: true
                spacing: Ui.tokens.spacing.sm

                ButtonIcon {
                    iconSize: 18
                    iconName: AudioService.sourceIcon
                    onClicked: AudioService.toggleSourceMute()
                }

                RavenText {
                    text: "Mic"
                }

                Item {
                    Layout.fillWidth: true
                }
                // Expand button
                ButtonIcon {
                    iconSize: 18
                    iconName: Icons.carets.right
                    rotation: root.menuopen ? 90 : 0
                    onClicked: root.menuopen = !root.menuopen

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                radius: 5
                value: AudioService.sourceVolume
                onMoved: AudioService.setInputVolume(value)
                hoverEnabled: true
                wheelEnabled: true
                showTooltip: true
                tooltipPrefix: `Mic volume: ${Math.round(value * 100)}%`
            }
        }
    }

    Rectangle {
        implicitHeight: 200
        implicitWidth: root.width
        color: ColorService.colorPalette.backgroundSecondary_300
        radius: 18
        y: root.height + 10
        z: 99
        visible: root.menuopen
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Ui.tokens.spacing.md
            RavenText {
                text: "Audio Device:"
            }
            // flickable with audiooutputs
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: audioColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: audioColumn
                    width: parent.width
                    spacing: Ui.tokens.spacing.xs

                    Repeater {
                        model: AudioService.sinks

                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: 8
                            color: modelData.id === AudioService.sink?.id ? ColorService.colorPalette.accentPrimary : ColorService.colorPalette.backgroundSecondary_100
                            RavenText {
                                anchors.fill: parent
                                anchors.margins: Ui.tokens.spacing.sm

                                text: modelData.description || modelData.name || "Unknown"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: AudioService.setAudioSink(modelData)
                            }
                        }
                    }
                }
            }
            Rectangle {
                color: ColorService.colorPalette.backgroundSecondary_100
                Layout.preferredHeight: 1
                Layout.fillWidth: true
            }
            RavenText {
                text: "Mic Device:"
            }
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: micColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: micColumn
                    width: parent.width
                    spacing: Ui.tokens.spacing.xs

                    Repeater {
                        model: AudioService.sources

                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: 8
                            color: modelData.id === AudioService.source?.id ? ColorService.colorPalette.accentPrimary : ColorService.colorPalette.backgroundSecondary_100

                            RavenText {
                                anchors.fill: parent
                                anchors.margins: Ui.tokens.spacing.sm

                                text: modelData.description || modelData.name || "Unknown"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: AudioService.setAudioSource(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
