pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var config: settingsFile.adapter
    readonly property string configDir: Quickshell.env("RAVEN_CONFIG_DIR") || (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/raven/"
    readonly property string cacheDir: Quickshell.env("RAVEN_CACHE_DIR") || (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/raven/"

    readonly property string defaultAvatar: Quickshell.env("HOME") + "/.face"
    readonly property string defaultVideosDirectory: Quickshell.env("HOME") + "/Videos"
    readonly property string defaultWallpapersDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    
    // Functions to return monitor info
    function getMonitorNames() {
        let names = [];
        for (let i = 0; i < Quickshell.screens.length; i++) {
            const screen = Quickshell.screens[i];
            if (screen && screen.name) {
                names.push(screen.name);
            }
        }
        return names;
    }

    function getMonitorScales() {
        const arr = [];

        for (let i = 0; i < Quickshell.screens.length; i++) {
            const screen = Quickshell.screens[i];
            let scale = 1.0;

            if (screen && typeof screen.devicePixelRatio === "number" && !isNaN(screen.devicePixelRatio)) {
                scale = screen.devicePixelRatio;
            }

            arr.push(String(scale));
        }

        return arr;
    }

    FileView {
        id: settingsFile
        path: root.configDir + "config.json"
        printErrors: false
        watchChanges: true
        onFileChanged: {
            console.log("Config changed externally, sanitizing");
            // If monitors block is invalid, replace it
            if (!Array.isArray(settingsAdapter.monitors.scales)) {
                settingsAdapter.monitors.scales = root.getMonitorScales();
            }
            reload();
        }

        onAdapterUpdated: settingsFile.writeAdapter()
        onLoadFailed: {
            console.warn("Settings: load failed. Reinitializing config with defaults.");
            settingsFile.writeAdapter();
        }

        JsonAdapter {
            id: settingsAdapter
            
            property JsonObject bar: JsonObject {
                property string position: "left"
                property int verticalMargin: 4
                property int horizontalMargin: 4
            }
            
            property JsonObject notifications: JsonObject {
                property bool enableSounds: true
                property bool enablePopups: true
                property int popupDuration: 5
            }
            
            property JsonObject session: JsonObject {
                property string timeZone: "Europe/Tirane"
                property string locale: "en_US"
                property string keyboardLayout: "us"
                property bool keepAwake: false
            }
            property JsonObject nightLight: JsonObject {
              property  bool enabled: false
              property bool automatic: false
              property int temperature: 4200
              property int gamma: 300
            }
            property JsonObject wallpapers: JsonObject {
                property bool randomize: false
                property int changeInterval: 10
                property string directory: root.defaultWallpapersDirectory
                property string path: "/home/mikaelio/Pictures/Wallpapers/738019.jpg"
            }
            
            property JsonObject themes: JsonObject {
                property string currentTheme: "wallust"
                property string currentIconTheme: "Papirus"
                property string currentCursorTheme: "Bibata-Modern-Ice"
                property int cursorSize: 24
                property bool lightTheme: false
            }
            
            property JsonObject volume: JsonObject {
                property int step: 5
                property int maxLevel: 100
                property bool muted: false
                property real value: 1.0
            }
            
            property JsonObject fonts: JsonObject {
                property string primary: "Sans Serif"
                property string monospace: "Monospace"
                property string heavyFont: "Sans Serif Black"
            }
            
            property JsonObject monitors: JsonObject {
                property list<string> names: root.getMonitorNames()
                property list<string> scales: root.getMonitorScales()
            }
            
            property JsonObject panels: JsonObject {
                property int rounding: 20
            }
            
            property JsonObject power: JsonObject {
                property bool powerSaver: false
                property int screenOffTimeout: 600
                property int sleepTimeout: 1800
                property string powerProfile: "balanced"
            }
            
            property JsonObject gaming: JsonObject {
                property bool enabled: false
                property bool disableNotifications: true
                property bool boostPerformance: true
                property string powerProfile: "performance"
            }
            
            property JsonObject programming: JsonObject {
                property bool enabled: false
                property bool enableDarkTheme: true
                property bool enableDoNotDisturb: true
                property bool enableBreakReminders: true
                property int breakInterval: 60
            }
        }
    }
}
