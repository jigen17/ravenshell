// pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    readonly property color toggleEnabledColor: ColorService.colorPalette.accentPrimary
    readonly property color toggleBackgroundColor: Qt.alpha(root.toggleEnabledColor, 0.2)

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(ColorService.colorPalette.backgroundPrimary_300.r, ColorService.colorPalette.backgroundPrimary_300.g, ColorService.colorPalette.backgroundPrimary_300.b, 0.2)
        radius: 12

        border {
            width: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.2)
        }

    }

    RowLayout {
        anchors {
            fill: parent
            margins: Ui.tokens.spacing.sm
        }

        ButtonIcon {
            iconName: Icons.network.wifi.high
            buttonPadding: 10
            enabled: NetworkService.wifiEnabled
            enabledColor: root.toggleEnabledColor
            backgroundColor: root.toggleBackgroundColor
            onClicked: NetworkService.wifiEnabled = !NetworkService.wifiEnabled
        }

        ButtonIcon {
            iconName: Icons.bluetooth.enabled
            buttonPadding: 10
            enabled: BluetoothService.bluetoothEnabled
            enabledColor: root.toggleEnabledColor
            backgroundColor: root.toggleBackgroundColor
            onClicked: BluetoothService.toggleBluetooth()
        }

        ButtonIcon {
            iconName: NotifService.dndEnabled ? Icons.notifications.bellZ : Icons.notifications.bell
            buttonPadding: 10
            enabled: !NotifService.dndEnabled
            enabledColor: root.toggleEnabledColor
            backgroundColor: root.toggleBackgroundColor
            onClicked: NotifService.dndEnabled = enabled
        }

        ButtonIcon {
            iconName: Icons.utilities.contrast
            buttonPadding: 10
            enabled: Settings.config.themes.lightTheme
            enabledColor: root.toggleEnabledColor
            backgroundColor: root.toggleBackgroundColor
            onClicked: Settings.config.themes.lightTheme = !enabled
        }

        ButtonIcon {
            iconName: Icons.toggles.caffeine
            buttonPadding: 10
            enabled: GlobalStatesService.keepAwake
            enabledColor: root.toggleEnabledColor
            backgroundColor: root.toggleBackgroundColor
            onClicked: GlobalStatesService.keepAwake = !GlobalStatesService.keepAwake
        }

        ButtonIcon {
            iconName: Icons.devices.gamepad
            buttonPadding: 10
            enabled: GlobalStatesService.gameMode
            enabledColor: root.toggleEnabledColor
            backgroundColor: root.toggleBackgroundColor
            onClicked: GlobalStatesService.gameMode = !GlobalStatesService.gameMode
        }

    }

}
