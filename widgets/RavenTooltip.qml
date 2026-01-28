import QtQuick
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services

ToolTip {
    id: root
    property string tooltipText: ""
    property bool show: false
    text: tooltipText
    delay: 1000
    timeout: -1
    visible: show && tooltipText.length > 0
    padding: 10
    background: Item {
        Rectangle {
            anchors.fill: parent
            color: ColorService.colorPalette.backgroundSecondary
            radius: height / 3
            border.color: ColorService.colorPalette.accentPrimary
            border.width: 2
        }
    }
    
    contentItem: RavenText {
        text: root.tooltipText
    }
}
