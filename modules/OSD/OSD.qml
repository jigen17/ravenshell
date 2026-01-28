import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.config
import qs.widgets
import qs.assets

StyledPanel {
    id: root
    anchorPosition: "top"
    animationType: 1
    cornerRadius: 30
    margins: 20
    panelHeight: 20
    panelWidth: 280

    property string currentType: "sink"
    property real currentValue: 0
    property bool currentMuted: false
    property string currentIcon: ""

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.closeWindow()
    }

    function show(type, value, muted) {
        currentType = type;
        currentValue = value;
        currentMuted = muted;

        // Update icon based on type
        if (type === "sink") {
            currentIcon = AudioService.sinkIcon;
        } else if (type === "source") {
            currentIcon = AudioService.sourceIcon;
        } else if (type === "brightness") {
            currentIcon = BrightnessService.brightnessIcon;
        } else if (type === "layout") {
            currentIcon = "";
        }

        root.openWindow();
        hideTimer.restart();
    }

    contentItem: RowLayout {
      anchors.fill: parent
      spacing: Ui.tokens.spacing.sm
        // Icon - First (hidden for layout)
        RavenIcon {
            iconColor: root.currentMuted ? "#ef5350" : ColorService.colorPalette.textSecondary_300
            iconName: root.currentIcon
            iconSize: Ui.tokens.iconSize.sm
            Layout.alignment: Qt.AlignVCenter
            visible: root.currentType !== "layout"
        }
        // Progress bar - Second (hidden for layout)
        ClippingRectangle {
            id: trackBackground
            Layout.preferredWidth: 200
            Layout.preferredHeight: 10
            Layout.alignment: Qt.AlignVCenter
            radius: 5
            color: ColorService.colorPalette.backgroundSecondary_300
            clip: true
            visible: root.currentType !== "layout"

            Rectangle {
                id: progressFill
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                implicitWidth: parent.width * Math.min(1.0, Math.max(0.0, root.currentValue))
                implicitHeight: parent.height
                color: root.currentMuted ? "#ef5350" : ColorService.colorPalette.accentPrimary

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }

        // Percentage/Layout text - Third
        RavenText {
            fontSize: Ui.tokens.fontSize.sm
            font.weight: Font.Bold
            text: root.currentType === "layout" ? HyprlandService.currentLayout : Math.round(root.currentValue * 100) + "%"
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: root.currentType === "layout" ? implicitWidth : 45
        }
    }

    // Watch AudioService properties
    Connections {
        target: AudioService

        function onVolumeChanged() {
            root.show("sink", AudioService.volume, AudioService.sinkMuted);
        }

        function onSinkMutedChanged() {
            root.show("sink", AudioService.volume, AudioService.sinkMuted);
        }

        function onSourceVolumeChanged() {
            root.show("source", AudioService.sourceVolume, AudioService.sourceMuted);
        }

        function onSourceMutedChanged() {
            root.show("source", AudioService.sourceVolume, AudioService.sourceMuted);
        }
    }

    // Watch BrightnessService properties
    Connections {
        target: BrightnessService

        function onBrightnessValueChanged() {
            root.show("brightness", BrightnessService.brightness, false);
        }
    }

    // Watch HyprlandService for keyboard layout changes
    Connections {
        target: HyprlandService

        function onCurrentLayoutChanged() {
            root.show("layout", 0, false);
        }
    }
}
