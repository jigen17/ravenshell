import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.config
import qs.services
import qs.assets
import qs.widgets

Rectangle {
  id: root
  color: ColorService.colorPalette.backgroundSecondary_300
  radius: 14

  RowLayout {
    anchors {
      fill: parent
      margins: Ui.tokens.spacing.sm
    }
      ButtonIcon {
        iconName: Icons.powerProfile.powerSave
        enabled: UpowerService.powerProfile === 0
        onClicked: UpowerService.toggleProfile(0)
        buttonPadding: 8
      }
      
      ButtonIcon {
        iconName: Icons.powerProfile.balanced
        enabled: UpowerService.powerProfile === 1
        onClicked: UpowerService.toggleProfile(1)
        buttonPadding: 8
      }
      
      ButtonIcon {
        iconName: Icons.powerProfile.performance
        enabled: UpowerService.powerProfile === 2
        onClicked: UpowerService.toggleProfile(2)
        buttonPadding: 8
      }
  }
}
