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

        active: true

        PanelWindow {
            id: backgroundWindow

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
                    return ;

                randomizeTransition();
                console.log("Wallpaper change ->", path);
                // Force reload if same path, then let onStatusChanged start the anim
                newWp.source = "";
                newWp.source = path;
            }

            WlrLayershell.layer: WlrLayer.Background
            exclusiveZone: 1
            WlrLayershell.namespace: "raven:wallpaper"
            screen: modelData
            color: ColorService.colorPalette.backgroundPrimary

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            ClippingRectangle {
                id: wpContainer

                radius: 12
                clip: true

                anchors {
                    fill: parent
                    margins: 0
                }

                // Old wallpaper — always visible, used as oldTexture by the shader
                Image {
                    id: oldWp

                    anchors.fill: parent
                    source: backgroundWindow.currentWallpaper
                    visible: true
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                }

                // New wallpaper — hidden, used as newTexture by the shader
                Image {
                    id: newWp

                    anchors.fill: parent
                    visible: false
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                    onStatusChanged: {
                        if (status === Image.Ready) {
                            transitionShader.transitionType = backgroundWindow.currentTransitionType;
                            transitionShader.progress = 0;
                            transitionShader.time = 0;
                            transitionShader.visible = true;
                            transitionAnim.start();
                        }
                    }
                }

                // Shader effect layer
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
                    function onCurrentWallpaperChanged() {
                        Qt.callLater(triggerTransition);
                    }

                    target: WallpaperService
                }

            }

            NumberAnimation {
                // newWp.source is kept so oldTexture stays valid until next transition

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
                    transitionShader.visible = false;
                }
            }

        }

    }

}
