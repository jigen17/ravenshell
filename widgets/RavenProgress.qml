import QtQuick
import qs.services

Item {
    id: root

    property real value: 0
    property color barColor: ColorService.colorPalette.accentPrimary
    property color backgroundColor: Qt.rgba(1, 1, 1, 0.06)
    property int animationDuration: 400

    // Track
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.backgroundColor
    }

    // Fill
    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, root.value))
        height: parent.height
        radius: height / 2
        color: root.barColor

        Behavior on width {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.InOutQuad
            }

        }

    }

}
