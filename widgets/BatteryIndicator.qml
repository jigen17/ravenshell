import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets
import qs.assets

Item {
    id: root
    implicitWidth:  40
    implicitHeight: 20

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Row {
        anchors.centerIn: parent
        spacing: 0

        // === Battery main pill ===
        ClippingRectangle {
            id: pill
            implicitWidth: root.implicitWidth - 4
            implicitHeight: root.implicitHeight
            radius: height / 4
            color: ColorService.colorPalette.textPrimary
            antialiasing: true

            // === Fill inside pill ===
            Rectangle {
                id: fill
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: Math.max(6,
                    (pill.width - 4) * UpowerService.batteryValue)

                antialiasing: true
                color: getBatteryColor()

                Behavior on width {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Loader {
                active: true
                anchors.centerIn: parent
                z: 99
                sourceComponent: UpowerService.isCharging ? chargingIcon : percentageText
            }

            Component {
                id: chargingIcon
                RavenIcon {
                  iconName: Icons.battery.lighting
                  iconColor: ColorService.colorPalette.backgroundPrimary
                  iconSize: Ui.tokens.iconSize.sm
                }
            }

            Component {
                id: percentageText
                RavenText {
                    text: Math.round(UpowerService.batteryValue * 100)
                    font.bold: true
                }
            }
        }

        // === Battery cap nub ===
        Rectangle {
            id: cap
            implicitWidth: 5
            implicitHeight: pill.height * 0.65
            anchors.verticalCenter: parent.verticalCenter
            topRightRadius: 4
            bottomRightRadius: 4
            antialiasing: true

            color: ColorService.colorPalette.textPrimary
            border.width: 1
            border.color: ColorService.colorPalette.backgroundPrimary
        }
    }

    // === Battery color logic ===
    function getBatteryColor() {
        if (UpowerService.batteryValue > 0.5)
            return "#34C759"

        if (UpowerService.batteryValue > 0.2)
            return "#FF9F0A"

            return "#dd3B50"
            console.log("Battery", UpowerService.batteryValue)
    }
}
