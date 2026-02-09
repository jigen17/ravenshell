import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.services
import qs.config

Item {
    id: root

    property Component contentItem: Item {}

    // Animation settings
    property int animationType: 0
    property int animationDuration: 250
    property int animationEasing: Easing.OutCubic

    // Position settings
    property string anchorPosition: "center"
    property int margins: 12
    property int screenMargin: 8
    
    // Appearance
    property bool closeOnClickOutside: true
    property real backgroundOpacity: 1
    property int cornerRadius: 12
    
    // Size - SET EXPLICITLY (children will follow)
    property int panelWidth: 400
    property int panelHeight: 300
    
    // Behavior
    property bool closeOnEscape: true
    property int hideDelay: 0
    property bool keyboardFocus: false
    
    // Signals
    signal opened
    signal closed
    signal aboutToOpen
    signal aboutToClose

    // Public methods
    function toggleWindow() {
        popupLoader.active ? closeWindow() : openWindow()
    }

    function openWindow() {
        aboutToOpen()
        popupLoader.active = true
        focusGrab.active = true
    }

    function closeWindow() {
        const popup = popupLoader.item
        if (popup && popup.container) {
            aboutToClose()
            popup.container.state = "closed"
        }
    }

    Timer {
        id: autoHideTimer
        interval: root.hideDelay
        running: false
        repeat: false
        onTriggered: closeWindow()
    }
    HyprlandFocusGrab {
      id: focusGrab
      windows: [root]
      onCleared: root.closeWindow()
    }
    Loader {
        id: popupLoader
        active: false
        
        sourceComponent: PanelWindow {
            id: popup

            property alias container: container

            anchors {
                top: root.anchorPosition === "top"
                bottom: root.anchorPosition === "bottom"
                left: root.anchorPosition === "left"
                right: root.anchorPosition === "right"
            }
            
            margins {
                top: root.anchorPosition === "top" ? root.screenMargin : 0
                bottom: root.anchorPosition === "bottom" ? root.screenMargin : 0
                left: root.anchorPosition === "left" ? root.screenMargin : 0
                right: root.anchorPosition === "right" ? root.screenMargin : 0
            }

            focusable: true
            visible: true
            color: "transparent"
            
            WlrLayershell.keyboardFocus: root.keyboardFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
            exclusiveZone: 0
            
            // Fixed size - no calculations
            implicitWidth: root.panelWidth + root.margins * 2
            implicitHeight: root.panelHeight + root.margins * 2

            Rectangle {
                id: container
                
                // Children follow parent
                anchors.fill: parent
                clip: true
                color: ColorService.colorPalette.backgroundPrimary
                radius: root.cornerRadius
                state: "closed"
                
                Component.onCompleted: state = "open"
                
                Keys.onEscapePressed: event => {
                    if (root.closeOnEscape) {
                        root.closeWindow()
                        event.accepted = true
                    }
                }

                transformOrigin: Item.Center

                transform: [
                    Scale {
                        id: scaleTransform
                        origin.x: container.width / 2
                        origin.y: root.animationType === 11 ? 0 : container.height / 2
                    },
                    Translate { id: translateTransform },
                    Rotation {
                        id: rotationTransform
                        origin.x: container.width / 2
                        origin.y: container.height / 2
                        axis {
                            x: root.animationType === 9 ? 1 : 0
                            y: root.animationType === 8 ? 1 : 0
                            z: root.animationType === 11 || root.animationType === 14 ? 1 : 0
                        }
                    }
                ]

                states: [
                    State {
                        name: "closed"
                        PropertyChanges {
                            container.opacity: 0
                            scaleTransform {
                                xScale: {
                                    switch (root.animationType) {
                                        case 0: case 6: return 0.9
                                        case 7: case 10: return 0.0
                                        case 12: return 0.8
                                        case 13: return 0.95
                                        default: return 1.0
                                    }
                                }
                                yScale: {
                                    switch (root.animationType) {
                                        case 0: case 6: return 0.9
                                        case 7: case 10: return 0.0
                                        case 12: return 1.2
                                        case 13: return 0.95
                                        default: return 1.0
                                    }
                                }
                            }
                            translateTransform {
                                x: {
                                    if (root.animationType === 3) return 40
                                    if (root.animationType === 4 || root.animationType === 10) return -40
                                    if (root.anchorPosition === "left") return -40
                                    if (root.anchorPosition === "right") return 40
                                    return 0
                                }
                                y: {
                                    if (root.animationType === 1) return -40
                                    if (root.animationType === 2 || root.animationType === 10) return 40
                                    if (root.animationType === 13) return 20
                                    if (root.anchorPosition === "top") return -40
                                    if (root.anchorPosition === "bottom") return 40
                                    return 0
                                }
                            }
                            rotationTransform {
                                angle: {
                                    if (root.animationType === 8 || root.animationType === 9) return 90
                                    if (root.animationType === 11) return -15
                                    if (root.animationType === 14) return 360
                                    return 0
                                }
                            }
                        }
                    },
                    State {
                        name: "open"
                        PropertyChanges {
                            container.opacity: root.backgroundOpacity
                            scaleTransform { xScale: 1.0; yScale: 1.0 }
                            translateTransform { x: 0; y: 0 }
                            rotationTransform.angle: 0
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "closed"
                        to: "open"
                        
                        SequentialAnimation {
                            ScriptAction {
                                script: {
                                    root.opened()
                                    if (root.hideDelay > 0) autoHideTimer.start()
                                }
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: container
                                    property: "opacity"
                                    duration: root.animationDuration
                                    easing.type: {
                                        if (root.animationType === 6 || root.animationType === 12) return Easing.OutBack
                                        if (root.animationType === 11) return Easing.OutElastic
                                        return root.animationEasing
                                    }
                                }
                                NumberAnimation {
                                    target: scaleTransform
                                    properties: "xScale,yScale"
                                    duration: root.animationDuration
                                    easing.type: {
                                        if (root.animationType === 6 || root.animationType === 12) return Easing.OutBack
                                        if (root.animationType === 11) return Easing.OutElastic
                                        return root.animationEasing
                                    }
                                }
                                NumberAnimation {
                                    target: translateTransform
                                    properties: "x,y"
                                    duration: root.animationDuration
                                    easing.type: {
                                        if (root.animationType === 6) return Easing.OutBack
                                        if (root.animationType === 11) return Easing.OutElastic
                                        return root.animationEasing
                                    }
                                }
                                NumberAnimation {
                                    target: rotationTransform
                                    property: "angle"
                                    duration: root.animationType === 11 ? root.animationDuration * 1.5 : root.animationDuration
                                    easing.type: {
                                        if (root.animationType === 11) return Easing.OutElastic
                                        if (root.animationType === 14) return Easing.OutBack
                                        return root.animationEasing
                                    }
                                }
                            }
                        }
                    },
                    Transition {
                        from: "open"
                        to: "closed"
                        
                        SequentialAnimation {
                            ScriptAction { script: autoHideTimer.stop() }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: container
                                    property: "opacity"
                                    duration: root.animationDuration * 0.8
                                    easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    target: scaleTransform
                                    properties: "xScale,yScale"
                                    duration: root.animationDuration * 0.8
                                    easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    target: translateTransform
                                    properties: "x,y"
                                    duration: root.animationDuration * 0.8
                                    easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    target: rotationTransform
                                    property: "angle"
                                    duration: root.animationDuration * 0.8
                                    easing.type: Easing.InCubic
                                }
                            }
                            ScriptAction {
                                script: {
                                    root.closed()
                                    popupLoader.active = false
                                }
                            }
                        }
                    }
                ]
                
                Loader {
                    id: contentLoader
                    
                    // Children fill parent with margins
                    anchors {
                        fill: parent
                        margins: root.margins 
                    }
                    
                    sourceComponent: root.contentItem
                    
                    onLoaded: if (item) item.forceActiveFocus()
                }
            }
        }
    }
}
