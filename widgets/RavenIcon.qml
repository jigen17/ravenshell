import QtQuick
import Quickshell
import qs.assets
import qs.config
import qs.services

Text {
    id: root
    property color iconColor: ColorService.colorPalette.textPrimary
    property  int iconSize: Ui.tokens.iconSize.sm
    property alias iconName: root.text
    color: root.iconColor
    font.family: Icons.font
    font.pixelSize: root.iconSize
    renderType: Text.HighRenderTypeQuality
    antialiasing: true
    smooth: true

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

}
