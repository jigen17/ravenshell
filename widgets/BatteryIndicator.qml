import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets
import qs.assets


Item {
    id: root
    implicitWidth: Ui.tokens.iconSize.xs
    implicitHeight: implicitWidth * 2
    scale: mouseFill.containsMouse ? 1.15 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
    MouseArea {
        id: mouseFill
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
    Rectangle {
        id: batteryBody
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: parent.implicitWidth
        implicitHeight: parent.implicitHeight * 0.9
        radius: 4
        color: "transparent"
        border.width: 2
        border.color: {
            if (UpowerService.isCharging || UpowerService.batteryValue > 0.3)
                return ColorService.colorPalette.textSecondary;
            else
            // green
            if (UpowerService.batteryValue > 0.1)
                return "#ff9500";
            else
                // orange
                return "#ff3b30"; // red
        }
        antialiasing: true

        Rectangle {
            id: batteryFill
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: Math.max(0, (parent.implicitHeight * UpowerService.batteryValue))
            radius: 4
            antialiasing: true

            color: {
                if (UpowerService.isCharging || UpowerService.batteryValue > 0.3)
                    return ColorService.colorPalette.textSecondary;
                else
                // green
                if (UpowerService.batteryValue > 0.1)
                    return "#ff9500";
                else
                    // orange
                    return "#ff3b30"; // red
            }

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: Icons.battery.lightning
            font.pixelSize: root.implicitWidth / 2
            visible: UpowerService.isCharging
            color: UpowerService.batteryValue > 0.1 ? ColorService.colorPalette.backgroundSecondary_300 : ColorService.colorPalette.textSecondary
            rotation: root.rotation
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !UpowerService.isCharging
            implicitWidth: batteryBody.implicitWidth
            implicitHeight: batteryBody.implicitHeight
            rotation: -root.rotation
            z: 99
            RavenText {
                anchors.centerIn: parent
                text: UpowerService.batteryValue * 100
                color: ColorService.colorPalette.backgroundSecondary_300
                fontSize: 10
                font.bold: true
            }
        }
    }

    // Battery cap
    Rectangle {
        anchors.bottom: batteryBody.top
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: parent.width * 0.5
        implicitHeight: parent.implicitHeight * 0.1
        topRightRadius: 2
        topLeftRadius: 2
        antialiasing: true
        color: UpowerService.isCharging ? ColorService.colorPalette.textSecondary : (UpowerService.batteryValue > 0.2 ? ColorService.colorPalette.textSecondary : "#ff3b30")

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
