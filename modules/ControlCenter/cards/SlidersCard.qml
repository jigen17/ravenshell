pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.services
import qs.assets
import qs.widgets

Item {
    id: root
    readonly property color buttonColor: ColorService.colorPalette.backgroundSecondary_100
    readonly property real itemOpacity: 0.4
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(ColorService.colorPalette.backgroundPrimary_300.r, ColorService.colorPalette.backgroundPrimary_300.g, ColorService.colorPalette.backgroundPrimary_300.b, 0.2)
        radius: 12

        border {
            width: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.2)
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 15
        }

        RowLayout {
            spacing: 10
            Layout.fillWidth: true
            ButtonIcon {
                iconName: BrightnessService.brightnessIcon
                buttonPadding: 8
                iconSize: 16
                radius: 8
                backgroundColor: root.buttonColor
                opacity: root.itemOpacity
            }
            RavenSlider {
                Layout.fillWidth: true
                implicitHeight: 10
                value: BrightnessService.brightness

                onMoved: BrightnessService.setBrightness(value);
            }
            RavenText {
                text: `${Math.floor(BrightnessService.brightness * 100)}`
                opacity: root.itemOpacity
            }
        }
        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            ButtonIcon {
                iconName: AudioService.sinkIcon
                buttonPadding: 8
                iconSize: 16
                radius: 8
                backgroundColor: root.buttonColor
                opacity: root.itemOpacity
                onClicked: AudioService.toggleSinkMute();
            }
            RavenSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                value: AudioService.volume
                onMoved:AudioService.setVolume(value)
                                fillColor: ColorService.colorPalette.accentPrimary

            }
            RavenText {
                text: `${Math.floor(AudioService.volume * 100)}`
                opacity: root.itemOpacity
            }
        }
        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            ButtonIcon {
                iconName: AudioService.sourceIcon
                buttonPadding: 8
                iconSize: 16
                radius: 8
                backgroundColor: root.buttonColor
                opacity: root.itemOpacity
                onClicked: AudioService.toggleSourceMute();
            }
            RavenSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                value: AudioService.sourceVolume
                onMoved: AudioService.setInputVolume(value)
                fillColor: ColorService.colorPalette.accentPrimary
            }
            RavenText {
                text: `${Math.floor(AudioService.sourceVolume * 100)}`
                opacity: root.itemOpacity
            }
        }
    }
}
