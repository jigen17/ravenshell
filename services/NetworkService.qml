pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root
    
    readonly property var adapters: Networking.devices.values
    
    readonly property var wirelessAdapters: adapters.filter(
        adapter => adapter.type === DeviceType.Wifi
    )
    
    readonly property WifiDevice wifiAdapter: wirelessAdapters.find(
        device => device.connected
    ) ?? null
    
    readonly property WifiNetwork activeNetwork: wifiAdapter 
        ? wifiAdapter.networks.values.find(network => network.connected) 
        : null
    
    readonly property bool wifiEnabled: Networking.wifiEnabled
    
    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled
    }
    
    function securityType(value) {
        return WifiSecurityType.toString(value)
    }
}
