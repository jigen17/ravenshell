import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.assets

Variants {
    model: Quickshell.screens

    LazyLoader {
        id: root
        required property var modelData
        active: true

        PanelWindow {
            id: backgroundWindow

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "raven:wallpaper"
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            property string currentWallpaper: Settings.config.wallpapers.path

            // Animation settings
            readonly property var transitions: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
            readonly property var transitionNames: ["fade", "grow", "outer", "wipe-left", "wipe-right", "wipe-up", "wipe-down", "zoom", "wave", "spiral", "diamond", "pixelate"]
            readonly property int animDuration: 800

            property int currentTransitionType: 0

            function randomizeTransition() {
                currentTransitionType = transitions[Math.floor(Math.random() * transitions.length)];
                console.log("Transition:", transitionNames[currentTransitionType]);
            }

            function triggerTransition() {
                const path = backgroundWindow.currentWallpaper;
                if (!path)
                    return;
                randomizeTransition();
                console.log("Wallpaper change ->", path);

                newWp.source = path;
                transitionShader.transitionType = currentTransitionType;
                transitionShader.progress = 0;
                transitionShader.visible = true;  // Show shader for transition
                oldWp.visible = false;  // Hide direct wallpaper display
                transitionAnim.start();
            }

            Item {
                id: wpContainer
                anchors.fill: parent

                // Old wallpaper
                Image {
                    id: oldWp
                    anchors.fill: parent
                    source: backgroundWindow.currentWallpaper
                    visible: true  // Changed: visible by default
                    cache: false
                }

                // New wallpaper
                Image {
                    id: newWp
                    anchors.fill: parent
                    visible: false
                    cache: false
                }

                // Shader effect layer
                ShaderEffect {
                    id: transitionShader
                    anchors.fill: parent
                    visible: false  // Changed: hidden by default

                    property variant oldTexture: oldWp
                    property variant newTexture: newWp
                    property real progress: 0
                    property int transitionType: 0
                    property vector2d resolution: Qt.vector2d(width, height)
                    property real time: 0

                    // Reference external compiled shaders
                    vertexShader: "/home/mikaelio/ravenshell/assets/wallpaperTransition.vert.qsb"
                    fragmentShader: "/home/mikaelio/ravenshell/assets/wallpaperTransition.frag.qsb"

                    Timer {
                        interval: 16
                        running: transitionAnim.running
                        repeat: true
                        onTriggered: transitionShader.time += 0.016
                    }
                }

                Connections {
                    target: WallpaperService
                    function onCurrentWallpaperChanged() {
                        Qt.callLater(triggerTransition);
                    }
                }
            }

            NumberAnimation {
                id: transitionAnim
                target: transitionShader
                property: "progress"
                from: 0
                to: 1
                duration: animDuration
                easing.type: Easing.InOutCubic
                onStopped: {
                    oldWp.source = newWp.source;
                    transitionShader.time = 0;
                    transitionShader.visible = false;  // Hide shader after transition
                    oldWp.visible = true;  // Show the actual wallpaper
                }
            }
        }
    }
}
