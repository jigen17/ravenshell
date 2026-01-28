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
  radius: 18
  property string show: "calendar"
  ColumnLayout {
    anchors {
      fill: parent
      margins: Ui.tokens.spacing.md
    }
    RowLayout {
      Layout.fillWidth: true

      RavenTextButton {
        Layout.fillWidth: true
         Layout.preferredWidth: 1
        Layout.preferredHeight: 35
        backgroundColor: ColorService.colorPalette.accentPrimary_700
        text: "Calendar"
        enabled: root.show === "calendar"
        onClicked: root.show = "calendar"
        topLeftRadius: 15
        bottomLeftRadius: 15
        topRightRadius: 5
        bottomRightRadius: 5
      }
      RavenTextButton {
        Layout.fillWidth: true
         Layout.preferredWidth: 1
        Layout.preferredHeight: 35
        backgroundColor: ColorService.colorPalette.accentPrimary_700
        text: "Weather"
        enabled: root.show === "weather"
        onClicked: root.show = "weather"
        topRightRadius: 15
        bottomRightRadius: 15
        topLeftRadius: 5
        bottomLeftRadius: 5
      }
    }
    Rectangle {
      color: ColorService.colorPalette.backgroundSecondary_100
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: 20
    }
  }
}
