import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.assets
import qs.config
import qs.services

Variants {
    model: Quickshell.screens

    LazyLoader {
        id: root

        required property var modelData
        // ── Wallpaper source ──────────────────────────────────────────────
        property string currentWallpaper: Settings.config.wallpapers.path
        readonly property bool isVideo: currentWallpaper.endsWith(".mp4") || currentWallpaper.endsWith(".webm") || currentWallpaper.endsWith(".mkv")

        // Static wallpaper window — only alive when not a video
        active: !isVideo
        // Launch mpvpaper for video wallpapers
        onIsVideoChanged: {
            if (isVideo)
                Quickshell.execDetached(["mpvpaper", "-o", "loop", modelData.name, currentWallpaper]);
            else
                Quickshell.execDetached(["pkill", "mpvpaper"]);
        }

        // ── Static wallpaper window ───────────────────────────────────────
        PanelWindow {
            id: backgroundWindow

            // ── Transition helpers ────────────────────────────────────────
            readonly property var transitionNames: ["fade", "grow", "outer", "wipe-left", "wipe-right", "wipe-up", "wipe-down", "zoom", "wave", "spiral", "diamond", "pixelate"]
            readonly property int animDuration: 800
            property int currentTransitionType: 0

            function randomizeTransition() {
                currentTransitionType = Math.floor(Math.random() * transitionNames.length);
                console.log("Transition:", transitionNames[currentTransitionType]);
            }

            function triggerTransition() {
                const path = root.currentWallpaper; // FIX: was backgroundWindow.currentWallpaper
                if (!path)
                    return ;

                randomizeTransition();
                newWp.source = "";
                newWp.source = path;
            }

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "raven:wallpaper"
            exclusiveZone: 1
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // ── Back layer (visible at rest) ──────────────────────────────
            Image {
                id: oldWp

                anchors.fill: parent
                source: root.currentWallpaper // FIX: was backgroundWindow.currentWallpaper
                cache: false
            }

            // ── Incoming layer (fed into the shader) ──────────────────────
            Image {
                id: newWp

                anchors.fill: parent
                visible: false
                cache: false
                onStatusChanged: {
                    if (status !== Image.Ready)
                        return ;

                    transitionShader.transitionType = backgroundWindow.currentTransitionType;
                    transitionShader.progress = 0;
                    transitionShader.time = 0;
                    transitionShader.visible = true;
                    transitionAnim.start();
                }
            }

            // ── Transition shader ─────────────────────────────────────────
            ShaderEffect {
                id: transitionShader

                property variant oldTexture: oldWp
                property variant newTexture: newWp
                property real progress: 0
                property int transitionType: 0
                property vector2d resolution: Qt.vector2d(width, height)
                property real time: 0

                anchors.fill: parent
                visible: false
                // Paths relative to the shell root — avoids hardcoded home dir
                vertexShader: Qt.resolvedUrl("./../../assets/wallpaperTransition.vert.qsb")
                fragmentShader: Qt.resolvedUrl("./../../assets/wallpaperTransition.frag.qsb")

                Timer {
                    interval: 16
                    running: transitionAnim.running
                    repeat: true
                    onTriggered: transitionShader.time += 0.016
                }

            }

            NumberAnimation {
                id: transitionAnim

                target: transitionShader
                property: "progress"
                from: 0
                to: 1
                duration: backgroundWindow.animDuration
                easing.type: Easing.InOutCubic
                onStopped: {
                    oldWp.source = newWp.source;
                    transitionShader.time = 0;
                    transitionShader.visible = false;
                }
            }

            // ── React to wallpaper service changes ────────────────────────
            Connections {
                function onCurrentWallpaperChanged() {
                    Qt.callLater(backgroundWindow.triggerTransition);
                }

                target: WallpaperService
            }

        }

    }

}
