import QtQuick
import QtQuick.Controls
import qs.services

Slider {
    id: root

    property color fillColor: ColorService.colorPalette.accentSecondary
    property int radius: 8

    from: 0
    to: 1
    live: true
    wheelEnabled: true

    background: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: root.availableWidth
        height: root.height * 0.5
        radius: root.radius
        color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.1)

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: root.fillColor
        }

    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * root.availableWidth - width / 2
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.height
        height: width
        radius: width / 2
        color: "#ffffff"
    }

}
