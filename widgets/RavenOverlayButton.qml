import QtQuick
import Quickshell
import qs.assets
import qs.config
import qs.services

Item {
    id: root

    // The "Main" icon that stays centered
    property string iconName: ""
    property int iconSize: 24
    property color iconColor: ColorService.colorPalette.textPrimary
    // The "Background/Badge" icon in the top right
    property string bgIconName: ""
    property int bgIconSize: 22
    property color bgIconColor: ColorService.colorPalette.textPrimary
    property bool hasBgIcon: bgIconName !== ""
    property color backgroundColor: "transparent"
    property color hoverColor: Qt.lighter(backgroundColor, 1.2)
    property color enabledColor: ColorService.colorPalette.accentonPrimary
    property color pressedColor: Qt.darker(hoverColor, 1.1)
    property int buttonPadding: 10
    property bool enabled: false
    property bool roundButton: true
    property int radius: 16

    signal clicked()

    implicitWidth: mainIcon.implicitWidth + buttonPadding * 2
    implicitHeight: implicitWidth

    // 1. Main Button Background
    Rectangle {
        id: background

        anchors.fill: parent
        radius: root.enabled && root.roundButton ? root.radius + 10 : root.radius
        // Original binding - it's fine as is
        color: {
            if (root.enabled)
                return root.enabledColor;

            if (mouseArea.pressed)
                return root.pressedColor;

            if (mouseArea.containsMouse)
                return root.hoverColor;

            return root.backgroundColor;
        }
        antialiasing: true
        scale: mouseArea.pressed ? 0.95 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }

        }

        Behavior on radius {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }

        }

    }

    // 2. The "Background Icon" (Top Right)
    // We give it a higher Z so it sits "on top" of the corner
    RavenIcon {
        id: cornerIcon

        z: 2
        visible: root.hasBgIcon
        iconName: root.bgIconName
        iconSize: root.bgIconSize
        color: root.bgIconColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 4
        // Slight rotation or opacity can make it look "background-ish"
        opacity: 0.8
    }

    // 3. The Main Tab Icon (Centered)
    RavenIcon {
        id: mainIcon

        z: 1
        anchors.centerIn: parent
        iconName: root.iconName
        iconSize: root.iconSize
        color: root.iconColor
        // Scale effect on hover
        scale: mouseArea.containsMouse ? 1.1 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 200
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

}
