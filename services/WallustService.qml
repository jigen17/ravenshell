pragma Singleton
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root
    readonly property bool useWallustColors: Settings.config.themes.currentTheme === "wallust"
    function startWallustService() {
        if (root.useWallustColors) {
            console.log("started wallust color generation");
            Quickshell.execDetached(["wallust", "run", `${Settings.config.wallpapers.path}`]);
        }
    }
}
