pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    readonly property var adapters: Bluetooth.adapters.values
    readonly property BluetoothAdapter selectedAdapter: Bluetooth.defaultAdapter
    readonly property var devices: selectedAdapter ? selectedAdapter.devices.values : []
    readonly property BluetoothDevice connectedDevice: devices.find(device => device.connected) || null
    readonly property bool bluetoothEnabled: selectedAdapter ? selectedAdapter.enabled : false
    readonly property string deviceBattery: connectedDevice.batteryAvailable ? `${connectedDevice.battery * 100} %` : ""
    function toggleBluetooth() {
        if (selectedAdapter) {
            selectedAdapter.enabled = !selectedAdapter.enabled;
        }
    }
}  
