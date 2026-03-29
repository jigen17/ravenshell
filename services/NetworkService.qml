import QtQuick
import Quickshell
import Quickshell.Networking
pragma Singleton

Singleton {
    id: root

    readonly property var adapters: Networking.devices.values
    readonly property var wirelessAdapters: adapters.filter((adapter) => {
        return adapter.type === DeviceType.Wifi;
    })
    readonly property WifiDevice wifiAdapter: wirelessAdapters.find((device) => {
        return device.connected;
    }) ?? null
    readonly property WifiNetwork activeNetwork: wifiAdapter ? wifiAdapter?.networks.values.find((network) => {
        return network.connected;
    }) : null
    readonly property bool wifiEnabled: Networking.wifiEnabled



    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function securityType(value) {
        return WifiSecurityType.toString(value);
    }

  onWifiAdapterChanged: {
    if (root.wifiAdapter && !scanTimer.running) {
        root.wifiAdapter.scannerEnabled = true;
    }
}


}
