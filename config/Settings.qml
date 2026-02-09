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
                property bool enabled: false
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
            
            // ========== DESKTOP SHELL ESSENTIALS ==========
            
            property JsonObject workspaces: JsonObject {
                property int count: 4
                property bool wrapAround: true
                property bool showIndicator: true
                property bool perMonitor: false
            }
            
            property JsonObject windowManagement: JsonObject {
                property int windowGap: 8
                property int borderWidth: 2
                property bool smartGaps: true
                property bool focusFollowsMouse: false
                property string defaultLayout: "tiling"
                property bool enableAnimations: true
                property int animationDuration: 200
                property bool centerNewWindows: true
                property list<string> floatingRules: ["float", "dialog", "splash"]
            }
            
            property JsonObject launcher: JsonObject {
                property bool fuzzySearch: true
                property int maxResults: 8
                property bool showRecent: true
                property int recentLimit: 5
                property list<string> favoriteApps: []
                property string searchProvider: "local"
                property bool showIcons: true
                property bool showDescriptions: true
            }
            
            property JsonObject systemTray: JsonObject {
                property bool enabled: true
                property bool showHidden: false
                property int iconSize: 20
                property int iconSpacing: 8
                property list<string> hiddenItems: []
            }
            
            property JsonObject quickSettings: JsonObject {
                property bool enabled: true
                property list<string> visibleToggles: ["wifi", "bluetooth", "nightlight", "dnd"]
                property bool showBrightnessSlider: true
                property bool showVolumeSlider: true
                property bool showNetworkDetails: true
                property bool showBatteryPercentage: true
            }
            
            property JsonObject dock: JsonObject {
                property bool enabled: false
                property string position: "bottom"
                property int iconSize: 48
                property bool autohide: false
                property int autohideDelay: 300
                property bool showRunningIndicator: true
                property list<string> pinnedApps: []
                property int maxIconZoom: 60
                property bool showOnAllMonitors: false
            }
            
            property JsonObject screenshot: JsonObject {
                property string saveDirectory: root.defaultVideosDirectory + "/../Screenshots"
                property string format: "png"
                property bool copyToClipboard: true
                property bool showNotification: true
                property bool includePointer: false
                property int quality: 95
            }
            
            property JsonObject media: JsonObject {
                property bool showPlayerControls: true
                property bool showAlbumArt: true
                property int maxTitleLength: 40
                property bool preferCoverArt: true
                property bool enableThumbnails: true
            }
            
            property JsonObject keyboard: JsonObject {
                property int repeatDelay: 300
                property int repeatRate: 25
                property bool numLockOnStartup: true
                property list<string> layouts: ["us"]
                property string switchShortcut: "Alt+Shift"
            }
            
            property JsonObject mouse: JsonObject {
                property real sensitivity: 1.0
                property bool naturalScrolling: false
                property bool middleClickPaste: true
                property int doubleClickTime: 400
                property bool accelerationEnabled: true
                property real accelerationProfile: 0.5
            }
            
            property JsonObject effects: JsonObject {
                property bool blur: true
                property int blurStrength: 8
                property bool shadows: true
                property int shadowSize: 12
                property bool roundedCorners: true
                property int cornerRadius: 12
                property bool fadeWindows: true
                property int fadeDuration: 150
            }
            
            property JsonObject appGrid: JsonObject {
                property int columns: 6
                property int iconSize: 64
                property bool showCategories: true
                property string sortBy: "name"
                property bool showSearchBar: true
            }
            
            property JsonObject hotkeys: JsonObject {
                property string launcher: "Super_L"
                property string terminal: "Super+Return"
                property string fileManager: "Super+E"
                property string browser: "Super+B"
                property string closeWindow: "Super+Q"
                property string screenshot: "Print"
                property string screenshotArea: "Shift+Print"
                property string lockScreen: "Super+L"
            }
            
            property JsonObject clipboard: JsonObject {
                property bool enabled: true
                property int historySize: 50
                property bool syncPrimary: false
                property list<string> ignoredTypes: ["password", "secret"]
            }
            
            property JsonObject taskbar: JsonObject {
                property bool enabled: true
                property bool groupByApp: true
                property bool showLabels: false
                property bool showMinimized: true
                property int maxButtonWidth: 200
            }
            
            property JsonObject calendar: JsonObject {
                property bool show24Hour: true
                property bool showWeekNumbers: false
                property int firstDayOfWeek: 1
                property bool showUpcomingEvents: true
            }
            
            property JsonObject weather: JsonObject {
                property bool enabled: true
                property string location: ""
                property string unit: "celsius"
                property real latitude: 0
                property real longitude: 0
                property int updateInterval: 30
            }
            
            property JsonObject autostart: JsonObject {
                property list<string> applications: []
                property int delay: 2
            }
        }
    }
}
