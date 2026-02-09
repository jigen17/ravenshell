pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var tokens: uiFile.adapter
    property real scale: 1.0

    FileView {
        id: uiFile
        path: Settings.configDir + "ui.json"
        printErrors: false
        watchChanges: true

        onFileChanged: {
            console.log("UiSettings", "Reloading UI settings");
            reload();
            root.scalechanged();
        }

        onAdapterUpdated: uiFile.writeAdapter()

        onLoadFailed: {
            console.log("UiSettings", "UI settings file missing, writing defaults");
            writeAdapter();
        }

        JsonAdapter {
            id: uiAdapter

            // Standard desktop icon sizes: 16, 24, 32, 48, 64
            property JsonObject iconSize: JsonObject {
                property real xs: 14 * root.scale  // Small toolbar icons
                property real sm: 22 * root.scale  // Standard toolbar/menu icons
                property real md: 24 * root.scale  // Medium buttons
                property real lg: 48 * root.scale  // Large icons/app lists
                property real xl: 64 * root.scale  // Extra large application icons
            }

            // 8-point grid spacing
            property JsonObject spacing: JsonObject {
                property real xs: 4 * root.scale
                property real sm: 8 * root.scale
                property real md: 16 * root.scale
                property real lg: 32 * root.scale
                property real xl: 64 * root.scale
            }

            // Standardized padding scale
            property JsonObject padding: JsonObject {
                property real xs: 2 * root.scale
                property real sm: 4 * root.scale
                property real md: 16 * root.scale
                property real lg: 16 * root.scale
                property real xl: 32 * root.scale
            }

            // Border radius scale
            property JsonObject radius: JsonObject {
                property real xs: 4 * root.scale
                property real sm: 6 * root.scale
                property real md: 8 * root.scale
                property real lg: 12 * root.scale
                property real xl: 999  // Full circle/pill shape
            }

            // Typography scale
            property JsonObject fontSize: JsonObject {
                property real xs: 12 * root.scale
                property real sm: 14 * root.scale
                property real md: 16 * root.scale
                property real lg: 20 * root.scale
                property real xl: 24 * root.scale
            }
        }
    }
}
