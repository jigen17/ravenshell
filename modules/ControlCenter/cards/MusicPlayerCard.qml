import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Widgets
import qs.services
import qs.config
import qs.widgets
import qs.assets

Item {
    id: root

    // --- Background Layer ---
    ClippingRectangle {
        anchors.fill: parent
        radius: 12
        color: ColorService.colorPalette.accentPrimary_300
        border {
            width: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r,ColorService.colorPalette.textPrimary.g,ColorService.colorPalette.textPrimary.b,0.2);
        }

        Image {
            id: backgroundImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: MprisService.activePlayer?.trackArtUrl
        }

        MultiEffect {
            source: backgroundImage
            anchors.fill: parent
            blurEnabled: true
            blur: 1.0
            blurMax: 48
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 15
        }
        spacing: 1

        // --- Album Art ---
        ClippingRectangle {
            Layout.preferredHeight: 150
            Layout.preferredWidth: 150
            Layout.alignment: Qt.AlignHCenter
            radius: 12

            Image {
                anchors.fill: parent
                source: MprisService.activePlayer?.trackArtUrl
            }
            MultiEffect {
                anchors.fill: parent
                shadowEnabled: true
                shadowColor: Qt.rgba(250, 250, 250, 0.6)
                shadowBlur: 1.0
                shadowVerticalOffset: 6
                shadowHorizontalOffset: 0
            }
        }

        Rectangle {
            implicitWidth: playerName.width + 20
            implicitHeight: playerName.height + 10
            Layout.alignment: Qt.AlignHCenter
            color: Qt.rgba(255, 255, 255, 0.15)
            radius: 10
            RavenText {
                id: playerName
                anchors.centerIn: parent
                text: MprisService.activePlayer?.identity
                fontSize: 16
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            RavenSlidingText {
                Layout.fillWidth: true
                text: MprisService.activePlayer?.trackTitle
                font.bold: true
                font.pixelSize: 16
                running: MprisService.activePlayer?.isPlaying
            }
            RavenSlidingText {
                Layout.fillWidth: true
                text: MprisService.activePlayer?.trackArtist || "..."
                font.pixelSize: 12
                font.weight: 500
                running: MprisService.activePlayer?.isPlaying
            }
        }

        Item {
            Layout.preferredHeight: 30
            Layout.fillWidth: true

            RowLayout {
                anchors.centerIn: parent
                Repeater {
                    model: 20
                    delegate: Rectangle {
                        required property int index
                        Layout.alignment: Qt.AlignVCenter
                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: ColorService.colorPalette.accentPrimary
                            }
                            GradientStop {
                                position: 0.5
                                color: ColorService.colorPalette.accentonSecondary
                            }
                            GradientStop {
                                position: 1
                                color: ColorService.colorPalette.accentPrimary
                            }
                        }
                        implicitWidth: 4
                        implicitHeight: CavaService.values[index] || 2
                        Behavior on implicitHeight {
                            NumberAnimation {
                                duration: 80
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }
        // --- Control Panel ---
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: controlsRow.implicitWidth + 12
            Layout.preferredHeight: controlsRow.implicitHeight + 10

            radius: 14
            // Dark background with opacity
            color: Qt.rgba(ColorService.colorPalette.backgroundSecondary_300.r, ColorService.colorPalette.backgroundSecondary_300.g, ColorService.colorPalette.backgroundSecondary_300.b, 0.5)
            RowLayout {
                id: controlsRow
                anchors.centerIn: parent
                spacing: 4
                ButtonIcon {
                    iconFamily: "Phosphor-Fill"
                    iconSize: 12
                    iconName: Icons.player.repeat
                    onClicked: MprisService.activePlayer.loopState = 2
                    buttonPadding: 10
                    radius: 10
                    backgroundColor: Qt.rgba(255, 255, 255, 0.15)
                }

                ButtonIcon {
                    iconFamily: "Phosphor-Fill"
                    iconSize: 12
                    iconName: Icons.player.previous
                    onClicked: MprisService.previousTrack()
                    buttonPadding: 10
                    radius: 10
                    backgroundColor: Qt.rgba(255, 255, 255, 0.15)
                }

                ButtonIcon {
                    iconFamily: "Phosphor-Fill"
                    iconSize: 12
                    iconName: MprisService.activePlayer.isPlaying ? Icons.player.pause : Icons.player.play
                    onClicked: MprisService.toggleTrack()
                    buttonPadding: 10
                    radius: 10
                    backgroundColor: Qt.rgba(255, 255, 255, 0.15)
                }

                ButtonIcon {
                    iconFamily: "Phosphor-Fill"
                    iconSize: 12
                    iconName: Icons.player.next
                    onClicked: MprisService.nextTrack()
                    buttonPadding: 10
                    radius: 10
                    backgroundColor: Qt.rgba(255, 255, 255, 0.15)
                }

                ButtonIcon {
                    iconFamily: "Phosphor-Fill"
                    iconSize: 12
                    iconName: Icons.player.shuffle
                    buttonPadding: 10
                    onClicked: MprisService.activePlayer.shuffle = !MprisService.activePlayer.shuffle
                    enabled: MprisService.activePlayer?.shuffle
                    radius: 10
                    backgroundColor: Qt.rgba(255, 255, 255, 0.15)
                }
            }
        }
    }
}
