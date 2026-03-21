import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.assets
import qs.widgets


RowLayout {
    spacing: 8
    Rectangle {
        implicitWidth: 120
        implicitHeight: 70
        radius: 18
        color: ColorService.colorPalette.backgroundSecondary_300
        RowLayout {
            anchors {
                fill: parent
                margins: 8
            }
            ButtonIcon {
                iconName: !NetworkService.activeNetwork ? Icons.network.wifi.off : (NetworkService.activeNetwork.signalStrength > 0.7 ? Icons.network.wifi.high : NetworkService.activeNetwork.signalStrength > 0.5 ? Icons.network.wifi.medium : Icons.network.wifi.low)
                buttonPadding: 15
                backgroundColor: ColorService.colorPalette.backgroundSecondary_100
                roundButton: false

                enabled: NetworkService.wifiEnabled
                onClicked: NetworkService.toggleWifi()
            }
            Column {
                Layout.fillWidth: true
                spacing: 0
                RavenText {
                    text: NetworkService.activeNetwork?.name ?? "Off"
                    fontSize: 12
                    elide: Text.ElideRight
                }
                RavenText {
                    text: NetworkService.securityType(NetworkService.activeNetwork?.security)
                    fontSize: 10
                    opacity: 0.7
                }
            }
        }
    }

    Rectangle {
        id: bluetoothCard

        implicitWidth: 200
        implicitHeight: 70
        radius: 18
        color: ColorService.colorPalette.backgroundSecondary_300

        RowLayout {
            anchors {
                fill: parent
                margins: 8
            }
            ButtonIcon {
                iconName: BluetoothService.connectedDevice ? Icons.bluetooth.connected : (BluetoothService.selectedAdapter?.state === 1 ? Icons.bluetooth.enabled : Icons.bluetooth.off)
                buttonPadding: 15
                roundButton: false
                backgroundColor: ColorService.colorPalette.backgroundSecondary_100
                enabled: BluetoothService.bluetoothEnabled
                onClicked: BluetoothService.toggleBluetooth()
            }
            Column {
                Layout.fillWidth: true
                spacing: 0
                RavenText {
                    text: BluetoothService.bluetoothEnabled ? "On" : "Off"
                    fontSize: 12
                }
                RavenText {
                    text: (BluetoothService.connectedDevice?.name ?? "...") + (BluetoothService.connectedDevice?.batteryAvailable ? (" · " + BluetoothService.connectedDevice.battery * 100 + "%") : "")
                    fontSize: 10
                    opacity: 0.7
                    elide: Text.ElideRight
                }
            }
        }
    }
}
