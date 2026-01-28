pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.assets
import qs.config

Singleton {
    id: root
    
    // Battery value normalized 0..1
    readonly property real batteryValue: UPower.displayDevice.percentage
    readonly property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging
    readonly property int powerProfile: PowerProfiles.profile
    

    // Helper function to convert string to PowerProfile enum
    function stringToProfile(profileString) {
        switch(profileString.toLowerCase()) {
            case "performance":
                return PowerProfile.Performance;
            case "balanced":
                return PowerProfile.Balanced;
            case "powersaver":
            case "power_saver":
                return PowerProfile.PowerSaver;
            default:
                console.warn("Unknown profile string:", profileString, "- defaulting to Balanced");
                return PowerProfile.Balanced;
        }
    }
    
    function toggleProfile(value) {
        // Prevent profile changes if gaming mode is active
        if (Settings.config.gaming.enabled && Settings.config.gaming.boostPerformance) {
            console.warn("Cannot change power profile while gaming mode is active");
            return;
        }
        
        PowerProfiles.profile = value;
        Settings.config.power.powerProfile = PowerProfile.toString(value);
    }
    
    Connections {
        target: Settings.config.gaming
        function onEnabledChanged() {
            if (Settings.config.gaming.enabled && Settings.config.gaming.boostPerformance) {
                // Switch to Performance when gaming mode is enabled
                PowerProfiles.profile = PowerProfile.Performance;
            } else {
                // Restore saved profile when gaming mode is disabled
                PowerProfiles.profile = stringToProfile(Settings.config.power.powerProfile);
            }
        }
    }
    
    Component.onCompleted: {
        if (Settings.config.gaming.enabled && Settings.config.gaming.boostPerformance) {
            PowerProfiles.profile = PowerProfile.Performance;
        } else {
            // Restore saved profile from string
            PowerProfiles.profile = stringToProfile(Settings.config.power.powerProfile);
        }
    }
}
