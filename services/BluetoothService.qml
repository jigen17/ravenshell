pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    readonly property var adapters: Bluetooth.adapters.values
    readonly property BluetoothAdapter selectedAdapter: Bluetooth.defaultAdapter
    readonly property var devices: selectedAdapter ? selectedAdapter.devices.values : []
    readonly property var connectedDevice: devices.find(device => device.connected) ?? null
    readonly property var pairedDevices: devices.filter(device => device.paired && !device.connected)
    readonly property var unknownDevices: devices.filter(device => !device.paired)
    readonly property bool bluetoothEnabled: selectedAdapter ? selectedAdapter.enabled : false
    readonly property string deviceBattery: (connectedDevice && connectedDevice.batteryAvailable) ? `${Math.round(connectedDevice.battery * 100)}%` : ""
    
    property int scanDuration: 60000   // 60 seconds
    property bool wasConnected: false
    
    // Monitor connection changes
    onConnectedDeviceChanged: {
        if (connectedDevice && !wasConnected) {
            // Device just connected
            console.log("Device connected:", connectedDevice.name, "→ stopping scan");
            scanStop();
            wasConnected = true;
        } else if (!connectedDevice && wasConnected) {
            // Device just disconnected
            console.log("Device disconnected");
            wasConnected = false;
            // Note: scan will NOT auto-restart, user must manually toggle
        }
    }
    
    Timer {
        id: scanTimer
        interval: scanDuration
        repeat: false
        onTriggered: {
            console.log("Bluetooth scan timeout reached → stopping scan");
            scanStop();
        }
    }
    
    function toggleBluetooth() {
        if (!selectedAdapter)
            return;
        selectedAdapter.enabled = !selectedAdapter.enabled;
    }
    
    function scanStart() {
        if (!selectedAdapter)
            return;
        if (selectedAdapter.discovering)
            return;
        console.log("Starting Bluetooth scan...");
        selectedAdapter.discovering = true;
        scanTimer.restart();
    }
    
    function scanStop() {
        if (!selectedAdapter)
            return;
        if (!selectedAdapter.discovering)
            return;
        console.log("Stopping Bluetooth scan...");
        selectedAdapter.discovering = false;
        scanTimer.stop();
    }
    
    function scanToggle() {
        if (!selectedAdapter)
            return;
        if (selectedAdapter.discovering)
            scanStop();
        else
            scanStart();
    }
    
    Component.onCompleted: {
        if (!selectedAdapter)
            return;
        selectedAdapter.discoverable = true;
        selectedAdapter.pairable = true;
        selectedAdapter.pairableTimeout = 45;
        
        // Initialize wasConnected state
        wasConnected = connectedDevice !== null;
        
        console.log("Bluetooth adapter ready:", selectedAdapter.name);
    }
}
