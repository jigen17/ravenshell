import QtQuick
import QtQuick.Layouts
import qs.services
import qs.widgets
import qs.config
import qs.assets

Item {
    Layout.fillHeight: true
    Layout.preferredWidth: 55

    Rectangle {
        anchors.fill: parent
        color: ColorService.colorPalette.textOverlay_900
        radius: 18
    }

    ColumnLayout {
        anchors.centerIn: parent

        spacing: 8
        Repeater {
            model: [
                {
                    icon: Settings.config.notifications.enablePopups ? Icons.notifications.bell : Icons.notifications.bellZ,
                    active: Settings.config.notifications.enablePopups,
                    toggle: () => Settings.config.notifications.enablePopups = !Settings.config.notifications.enablePopups
                },
                {
                    icon: Icons.media.palette,
                    active: Settings.config.themes.lightTheme,
                    toggle: () => Settings.config.themes.lightTheme = !Settings.config.themes.lightTheme
                },
                {
                    icon: Icons.toggles.moonstars,
                    active: Settings.config.nightLight.enabled,
                    toggle: () => Settings.config.nightLight.enabled = !Settings.config.nightLight.enabled
                },
                {
                    icon: Icons.devices.game_controller,
                    active: Settings.config.gaming.enabled,
                    toggle: () => Settings.config.gaming.enabled = !Settings.config.gaming.enabled
                },
                {
                    icon: Icons.toggles.caffeine,
                    active: GlobalStatesService.keepAwake,
                    toggle: () => GlobalStatesService.keepAwake = !GlobalStatesService.keepAwake
                }
            ]
            delegate: ButtonIcon {
                iconName: modelData.icon
                iconSize: Ui.tokens.iconSize.sm
                buttonPadding: 10
                backgroundColor: ColorService.colorPalette.backgroundSecondary_300
                enabledColor: ColorService.colorPalette.accentonPrimary
                enabled: modelData.active
                onClicked: modelData.toggle()
            }
        }
    }
}
