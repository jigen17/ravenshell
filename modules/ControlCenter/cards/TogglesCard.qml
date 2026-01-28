import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.widgets
import qs.assets

Rectangle {
  id: root
  color: ColorService.colorPalette.backgroundSecondary_300
  radius: 18
  RowLayout {
    anchors.fill: parent
    anchors.margins: Ui.tokens.spacing.sm
    ButtonIcon {
        iconName: Settings.config.notifications.enablePopups ? Icons.notifications.bell : Icons.notifications.bellZ
        buttonPadding: Ui.tokens.spacing.md
        onClicked: Settings.config.notifications.enablePopups = !Settings.config.notifications.enablePopups
        backgroundColor: ColorService.colorPalette.backgroundSecondary_100
        enabled: Settings.config.notifications.enablePopups
    }
    Item { Layout.fillWidth: true}
    ButtonIcon {
        iconName: Icons.media.palette
        buttonPadding: Ui.tokens.spacing.md
        onClicked: Settings.config.themes.lightTheme = !Settings.config.themes.lightTheme
        backgroundColor: ColorService.colorPalette.backgroundSecondary_100
        enabled: Settings.config.themes.lightTheme
      }
        Item { Layout.fillWidth: true}

    ButtonIcon {
        iconName: Icons.toggles.moonstars
        buttonPadding: Ui.tokens.spacing.md
        backgroundColor: ColorService.colorPalette.backgroundSecondary_100
        onClicked: Settings.config.nightLight.enabled =! Settings.config.nightLight.enabled
        enabled: Settings.config.nightLight.enabled
    }
    Item { Layout.fillWidth: true}

    ButtonIcon {
        iconName: Icons.devices.game_controller
        buttonPadding: Ui.tokens.spacing.md
        onClicked: Settings.config.gaming.enabled = !Settings.config.gaming.enabled
        backgroundColor: ColorService.colorPalette.backgroundSecondary_100
        enabled: Settings.config.gaming.enabled
      }
    Item { Layout.fillWidth: true}
      
    ButtonIcon {
        iconName: Icons.toggles.caffeine
        buttonPadding: Ui.tokens.spacing.md
        onClicked: Settings.config.session.keepAwake = !Settings.config.session.keepAwake
        backgroundColor: ColorService.colorPalette.backgroundSecondary_100
        enabled: Settings.config.session.keepAwake
      }

    }
  }
