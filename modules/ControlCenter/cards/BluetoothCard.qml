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
    color: BluetoothService.bluetoothEnabled ? ColorService.colorPalette.accentonPrimary : ColorService.colorPalette.backgroundSecondary_300

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    topLeftRadius: 10
    topRightRadius: 18
    bottomLeftRadius: 10
    bottomRightRadius: 18

    RowLayout {
        anchors.fill: parent
        anchors.margins: Ui.tokens.spacing.md
        spacing: Ui.tokens.spacing.sm

        ButtonIcon {
            iconName: {
                // First priority: Check if a device is connected
                if (BluetoothService.connectedDevice)
                    return Icons.bluetooth.connected;
                // Second priority: Check adapter state
                const state = BluetoothService.selectedAdapter?.state;
                if (state === 1)
                    return Icons.bluetooth.enabled;
                if (state === 5)
                    return Icons.bluetooth.x;
                // Default: Disabled or any other state
                return Icons.bluetooth.off;
            }
            iconSize: 24
            onClicked: BluetoothService.toggleBluetooth()
        }

        Column {
            spacing: 0
            RavenText {
                text: BluetoothService.bluetoothEnabled ? "Enabled" : "Disabled"
                fontSize: Ui.tokens.fontSize.sm
            }
            RowLayout {
                RavenText {
                  text: BluetoothService.connectedDevice ? BluetoothService.connectedDevice.name :  "..."
                    fontSize: Ui.tokens.fontSize.xs
                    opacity: 0.8
                }
                RavenText {
                    text: BluetoothService.deviceBattery
                    fontSize: Ui.tokens.fontSize.xs
                    opacity: 0.8
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ButtonIcon {
            iconName: Icons.carets.right
        }
    }
}
