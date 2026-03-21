import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "cards"
import qs.assets
import qs.config
import qs.services
import qs.widgets

StyledPanel {
    id: root

    anchorPosition: "top"
    margins: 15
    cornerRadius: 24
    panelWidth: 700
    panelHeight: 400

    KeyboardShortcut {
        name: "controlCenter"
        onPressed: root.toggleWindow()
    }

    contentItem: ColumnLayout {
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true

            Column {
                spacing: 0

                Row {
                    spacing: 2

                    RavenText {
                        text: TimeService.hourString
                        fontSize: 24
                    }

                    RavenText {
                        text: ":"
                        fontSize: 24
                        color: ColorService.colorPalette.accentonPrimary
                    }

                    RavenText {
                        text: TimeService.minuteString
                        fontSize: 24
                    }

                }

                RavenText {
                    text: TimeService.dayofWeek + ", " + TimeService.format("MMM dd")
                }

            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 8

                RavenText {
                    text: "mikaleio"
                    font.pixelSize: 12
                }

                ClippingRectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16

                    Image {
                        anchors.fill: parent
                        source: "///home/mikaelio/.face.icon"
                    }

                }

                ButtonIcon {
                    iconName: Icons.settings.gear
                    buttonPadding: 6
                }

                ButtonIcon {
                    iconName: Icons.power.shutdown
                    buttonPadding: 6
                }

                ButtonIcon {
                    iconName: Icons.utilities.dismiss
                    buttonPadding: 6
                    onClicked: root.closeWindow()
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: ColorService.colorPalette.textPrimary
            opacity: 0.15
        }

        // Main Content
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                WifiBluetoothRow {
                }

                RowLayout {
                    Layout.fillHeight: true

                    RavenSlider {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50
                        iconName: Icons.audio.speaker.high
                        value: AudioService.volume
                    }

                    RavenSlider {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50
                        iconName: Icons.audio.mic.mic
                        value: AudioService.sourceVolume
                    }

                }

            }

            MusicPlayerCard {
                Layout.fillHeight: true
                Layout.preferredWidth: 220
            }

            Item {
                Layout.fillWidth: true
            }

        }

    }

}
