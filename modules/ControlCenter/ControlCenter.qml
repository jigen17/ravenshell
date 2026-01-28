import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets
import qs.assets
import "cards"
StyledPanel {
    id: root
    
    KeyboardShortcut {
        name: "controlCenter"
        onPressed: root.toggleWindow()
    }
    
    anchorPosition: "left"
    margins: 20
    cornerRadius: 38
    panelWidth: 400
    panelHeight: 800
    contentItem: ColumnLayout {
      anchors.fill: parent
      spacing: Ui.tokens.spacing.sm
      UserCard {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: 40 + Ui.tokens.spacing.md * 2
        radius: 18
      }
      RowLayout {
        Layout.fillWidth: true

        WifiCard {
          Layout.fillWidth: true
           Layout.preferredWidth: 1
          Layout.preferredHeight: 40 + Ui.tokens.spacing.md * 2
        }
          BluetoothCard {
            Layout.fillWidth: true
             Layout.preferredWidth: 1
          Layout.preferredHeight: 40 + Ui.tokens.spacing.md * 2
        }
      }
      TogglesCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 40 + Ui.tokens.spacing.md * 2
      }
      RowLayout {
        Layout.fillWidth: true
        PowerProfileCard {
          Layout.preferredWidth: 140
          Layout.preferredHeight: 20 + Ui.tokens.spacing.md * 2
        }
        ButtonsCard {
          Layout.fillWidth: true
                    Layout.preferredHeight: 20 + Ui.tokens.spacing.md * 2
        }
      }
        BrightnessCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 40 + Ui.tokens.spacing.md * 2
        radius: 18
      }
      VolumeCard {
        Layout.fillWidth: true
        radius: 18
      }

      CalendarWeathercard {
        Layout.fillHeight: true
        Layout.fillWidth: true
      } 
    }
}
