import QtQuick
import qs.services

Rectangle {
    id: root

    property bool checked: false

    color: "transparent"
    radius: 2

    border {
        width: 1
        color: ColorService.colorPalette.textPrimary
    }

    Rectangle {
        color: ColorService.colorPalette.textPrimary
        radius: 2
        visible: root.checked

        anchors {
            fill: parent
            margins: 4
        }

    }

}
