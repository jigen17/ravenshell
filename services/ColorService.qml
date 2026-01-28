pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root
    property bool isLightTheme: Settings.config.themes.lightTheme
    property var colorPalette: wallustFile.adapter.wallust.dark
    onIsLightThemeChanged: {
        colorPalette = isLightTheme ? wallustFile.adapter.wallust.light : wallustFile.adapter.wallust.dark;
    }
    FileView {
        id: wallustFile
        path: "/home/mikaelio/.config/raven/wallust.json"
        printErrors: false
        watchChanges: true

        onFileChanged: {
            console.log("WallustService", "Reloading wallust colors");
            reload();
        }
        onAdapterUpdated: writeAdapter()
        onLoadFailed: {
            console.log("WallustService", "Colors file missing, writing defaults");
            writeAdapter();
        }

        JsonAdapter {
            id: wallustData
            property JsonObject wallust: JsonObject {
                property JsonObject dark: JsonObject {
                    property color backgroundPrimary_100: "#767677"
                    property color backgroundPrimary_300: "#48484A"
                    property color backgroundPrimary: "#1A1A1D"
                    property color backgroundPrimary_700: "#151517"
                    property color backgroundPrimary_900: "#101011"
                    property color backgroundSecondary_100: "#8D8D8F"
                    property color backgroundSecondary_300: "#676769"
                    property color backgroundSecondary: "#414144"
                    property color backgroundSecondary_700: "#343436"
                    property color backgroundSecondary_900: "#272729"
                    property color backgroundOverlay_100: "#8F998D"
                    property color backgroundOverlay_300: "#6A7767"
                    property color backgroundOverlay: "#455541"
                    property color backgroundOverlay_700: "#374434"
                    property color backgroundOverlay_900: "#293327"
                    property color textPrimary_100: "#F1F7D4"
                    property color textPrimary_300: "#EDF4C6"
                    property color textPrimary: "#E8F1B8"
                    property color textPrimary_700: "#BAC193"
                    property color textPrimary_900: "#8B916E"
                    property color textSecondary_100: "#E6EEBC"
                    property color textSecondary_300: "#DEE8A6"
                    property color textSecondary: "#D6E290"
                    property color textSecondary_700: "#ABB573"
                    property color textSecondary_900: "#808856"
                    property color textOverlay_100: "#BFC5A3"
                    property color textOverlay_300: "#AAB184"
                    property color textOverlay: "#959E65"
                    property color textOverlay_700: "#777E51"
                    property color textOverlay_900: "#595F3D"
                    property color accentPrimary_100: "#C8BA9E"
                    property color accentPrimary_300: "#B6A37D"
                    property color accentPrimary: "#A48C5D"
                    property color accentPrimary_700: "#83704A"
                    property color accentPrimary_900: "#625438"
                    property color accentSecondary_100: "#D7E685"
                    property color accentSecondary_300: "#CADE5C"
                    property color accentSecondary: "#BDD633"
                    property color accentSecondary_700: "#97AB29"
                    property color accentSecondary_900: "#71801F"
                    property color accentonPrimary_100: "#DD96B6"
                    property color accentonPrimary_300: "#D1739E"
                    property color accentonPrimary: "#C65086"
                    property color accentonPrimary_700: "#9E406B"
                    property color accentonPrimary_900: "#773050"
                    property color accentonSecondary_100: "#9CC4BF"
                    property color accentonSecondary_300: "#7BB1A9"
                    property color accentonSecondary: "#5A9D94"
                    property color accentonSecondary_700: "#487E76"
                    property color accentonSecondary_900: "#365E59"
                    property color accentTertiary_100: "#A99284"
                    property color accentTertiary_300: "#8D6E5B"
                    property color accentTertiary: "#704A32"
                    property color accentTertiary_700: "#5A3B28"
                    property color accentTertiary_900: "#432C1E"
                    property color border_100: "#CDC4AC"
                    property color border_300: "#BDB191"
                    property color border: "#AC9D75"
                    property color border_700: "#8A7E5E"
                    property color border_900: "#675E46"
                }
                property JsonObject light: JsonObject {
                    property color backgroundPrimary_100: "#767677"
                    property color backgroundPrimary_300: "#48484A"
                    property color backgroundPrimary: "#1A1A1D"
                    property color backgroundPrimary_700: "#151517"
                    property color backgroundPrimary_900: "#101011"
                    property color backgroundSecondary_100: "#8D8D8F"
                    property color backgroundSecondary_300: "#676769"
                    property color backgroundSecondary: "#414144"
                    property color backgroundSecondary_700: "#343436"
                    property color backgroundSecondary_900: "#272729"
                    property color backgroundOverlay_100: "#8F998D"
                    property color backgroundOverlay_300: "#6A7767"
                    property color backgroundOverlay: "#455541"
                    property color backgroundOverlay_700: "#374434"
                    property color backgroundOverlay_900: "#293327"
                    property color textPrimary_100: "#F1F7D4"
                    property color textPrimary_300: "#EDF4C6"
                    property color textPrimary: "#E8F1B8"
                    property color textPrimary_700: "#BAC193"
                    property color textPrimary_900: "#8B916E"
                    property color textSecondary_100: "#E6EEBC"
                    property color textSecondary_300: "#DEE8A6"
                    property color textSecondary: "#D6E290"
                    property color textSecondary_700: "#ABB573"
                    property color textSecondary_900: "#808856"
                    property color textOverlay_100: "#BFC5A3"
                    property color textOverlay_300: "#AAB184"
                    property color textOverlay: "#959E65"
                    property color textOverlay_700: "#777E51"
                    property color textOverlay_900: "#595F3D"
                    property color accentPrimary_100: "#C8BA9E"
                    property color accentPrimary_300: "#B6A37D"
                    property color accentPrimary: "#A48C5D"
                    property color accentPrimary_700: "#83704A"
                    property color accentPrimary_900: "#625438"
                    property color accentSecondary_100: "#D7E685"
                    property color accentSecondary_300: "#CADE5C"
                    property color accentSecondary: "#BDD633"
                    property color accentSecondary_700: "#97AB29"
                    property color accentSecondary_900: "#71801F"
                    property color accentonPrimary_100: "#DD96B6"
                    property color accentonPrimary_300: "#D1739E"
                    property color accentonPrimary: "#C65086"
                    property color accentonPrimary_700: "#9E406B"
                    property color accentonPrimary_900: "#773050"
                    property color accentonSecondary_100: "#9CC4BF"
                    property color accentonSecondary_300: "#7BB1A9"
                    property color accentonSecondary: "#5A9D94"
                    property color accentonSecondary_700: "#487E76"
                    property color accentonSecondary_900: "#365E59"
                    property color accentTertiary_100: "#A99284"
                    property color accentTertiary_300: "#8D6E5B"
                    property color accentTertiary: "#704A32"
                    property color accentTertiary_700: "#5A3B28"
                    property color accentTertiary_900: "#432C1E"
                    property color border_100: "#CDC4AC"
                    property color border_300: "#BDB191"
                    property color border: "#AC9D75"
                    property color border_700: "#8A7E5E"
                    property color border_900: "#675E46"
                }
            }
        }
    }
}

