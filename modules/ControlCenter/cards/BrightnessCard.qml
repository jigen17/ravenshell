import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets
import qs.assets

Rectangle {
    id: root
    color: ColorService.colorPalette.backgroundSecondary_300
    
    ColumnLayout {
        anchors {
            fill: parent
            margins: Ui.tokens.spacing.md
        }
        spacing: Ui.tokens.spacing.sm
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Ui.tokens.spacing.md
            
            RavenIcon {
                id: brightnessIconItem
                iconName: BrightnessService.brightnessIcon
                iconSize: 18
                Layout.alignment: Qt.AlignVCenter
            }
            
            RavenText {
                text: "Brightness"
            }
        }
        
        StyledSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            radius: 5
            value: BrightnessService.brightness
            onMoved: {
                BrightnessService.setBrightness(value)
            }
            hoverEnabled: true
            wheelEnabled: true
            showTooltip: true
            tooltipPrefix: `Brightness: ${Math.round(value * 100)}%`
        }
    }
}
