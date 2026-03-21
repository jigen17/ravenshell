import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    // Core properties
    property real value: 0.5
    property bool muted: false
    property string iconName: ""
    property color accentColor: ColorService.colorPalette.accentPrimary
    property int radius: 12

    ClippingRectangle {
        anchors.fill: parent
        radius: root.radius
        color: ColorService.colorPalette.accentPrimary_100
        clip: true
        smooth: true
        antialiasing: true

        Rectangle {
            id: fill

            implicitWidth: parent.width
            implicitHeight: parent.height * root.value
            anchors.bottom: parent.bottom
            smooth: true
            antialiasing: true
            color: root.muted ? "#444444" : root.accentColor

            Behavior on height {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        RavenIcon {
            id: toggleButton

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: root.iconName
            iconSize: 22
            font.weight: 600            
        }
    }

    // Interaction Area
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: (mouse) => {
            if (pressed) {
                let pos = 1 - (mouse.y / height);
                root.value = Math.max(0, Math.min(1, pos));
            }
        }
    }

}
