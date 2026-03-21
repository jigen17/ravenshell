import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.assets
import qs.widgets

Rectangle {
    id: root
    color: NetworkService.wifiEnabled 
           ? ColorService.colorPalette.backgroundSecondary_300
           : ColorService.colorPalette.backgroundSecondary
    
    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
    radius: 18
    RowLayout {
        anchors {
          fill: parent
          leftMargin: 10
        }
        spacing: Ui.tokens.spacing.sm
        
        ButtonIcon {
            iconName: {
                if (!NetworkService.activeNetwork) return Icons.network.wifi.none
                
                const strength = NetworkService.activeNetwork.signalStrength
                if (strength > 0.7) return Icons.network.wifi.high
                if (strength > 0.5) return Icons.network.wifi.medium
                if (strength > 0.2) return Icons.network.wifi.low
                return Icons.network.wifi.none
            }
            iconSize: 24
            onClicked: NetworkService.toggleWifi()
        }
        
        ColumnLayout {
            spacing: 0 
            RavenText {
                text: NetworkService.activeNetwork?.name ?? "Disabled"
                Layout.maximumWidth: 150
                elide: Text.ElideRight
                fontSize: Ui.tokens.fontSize.sm
            }
            
            RavenText {
                text: NetworkService.securityType(NetworkService.activeNetwork?.security)
                fontSize: Ui.tokens.fontSize.xs
                opacity: 0.8
            }
        }
        
        ButtonIcon {
          iconName: Icons.carets.right
          iconSize: 10
          buttonPadding: 8
          backgroundColor: ColorService.colorPalette.backgroundSecondary_100
        }
    }
}
