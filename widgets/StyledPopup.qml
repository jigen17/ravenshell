import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.config
Item {
    id: root

    // Required: Item to anchor the popup to (actual item instance, not Component)
    property var anchorItem: null

    // Content to display in the popup
    property Component contentItem: Item {}

    property int animationType: 4 //Settings.config.panels.popupAnimations
    property int animationDuration: 250
    property int animationEasing: Easing.OutCubic

    // Position offsets relative to anchor
    property int offsetX: 0
    property int offsetY: 0

    // Popup appearance
    property int margins: 12
    property bool closeOnClickOutside: true

    // Signals
    signal opened
    signal closed
    signal aboutToOpen
    signal aboutToClose

    // Public methods
    function toggleWindow() {
        if (popupLoader.active) {
            root.closeWindow();
        } else {
            root.openWindow();
        }
    }
    function openWindow() {
        root.aboutToOpen();
        popupLoader.active = true;
    }
    function closeWindow() {
        if (popupLoader.item && popupLoader.item.container) {
            root.aboutToClose();
            popupLoader.item.container.state = "closed";
        }
    }
    
    // Popup window loader
    Loader {
        id: popupLoader
        active: false
        sourceComponent: PopupWindow {
            id: popup

            visible: true
            color: "transparent"
            anchor.item: root.anchorItem
            anchor.rect.x: root.anchorItem ? root.anchorItem.width * 1.5 : 0
            
            // Size based on container
            implicitWidth: container.width
            implicitHeight: container.height
          
            property alias container: container
            // Click outside handler
            MouseArea {
                anchors.fill: parent
                enabled: root.closeOnClickOutside
                onClicked: root.closeWindow()
                z: -1
            }

            Rectangle {
                id: container
                
                // Size based on content, not parent
                implicitWidth: contentLoader.item ? contentLoader.item.implicitWidth + root.margins * 2 : 100
                implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight + root.margins * 2 : 100
                
                color: ColorService.colorPalette.backgroundSecondary
                radius: 15
                state: "closed"
                focus:true
                Keys.onEscapePressed: root.closeWindow();
                // Start invisible to prevent flicker
                visible: contentLoader.status === Loader.Ready
                
                // Calculate animation parameters based on type
                property real targetTranslateX: {
                    switch (root.animationType) {
                    case 3:  // SlideLeft
                        return 40;
                    case 4:  // SlideRight
                    case 10: // SlideScale
                        return -40;
                    default:
                        return 0;
                    }
                }
                
                property real targetTranslateY: {
                    switch (root.animationType) {
                    case 1:  // SlideDown
                        return -40;
                    case 2:  // SlideUp
                    case 10: // SlideScale
                        return 40;
                    case 13: // LiftUp
                        return 20;
                    default:
                        return 0;
                    }
                }
                
                property real targetScale: {
                    switch (root.animationType) {
                    case 0:  // Popup
                    case 6:  // Bounce (starts smaller)
                        return 0.8;
                    case 7:  // ZoomIn
                    case 10: // SlideScale
                        return 0.0;
                    case 12: // RubberBand
                        return 1.2;
                    case 13: // LiftUp
                        return 0.95;
                    default:
                        return 1.0;
                    }
                }
                
                property real targetRotation: {
                    switch (root.animationType) {
                    case 8:  // FlipHorizontal
                    case 9:  // FlipVertical
                        return 90;
                    case 11: // Swing
                        return -15;
                    case 14: // RollIn
                        return 360;
                    default:
                        return 0;
                    }
                }

                // Use transform for animations
                transform: [
                    Scale {
                        id: scaleTransform
                        origin.x: container.width / 2
                        origin.y: {
                            // Swing pivots from top
                            if (root.animationType === 11) return 0;
                            return container.height / 2;
                        }
                        xScale: 1.0
                        yScale: 1.0
                    },
                    Translate {
                        id: translateTransform
                        x: 0
                        y: 0
                    },
                    Rotation {
                        id: rotationTransform
                        origin.x: container.width / 2
                        origin.y: container.height / 2
                        axis {
                            x: root.animationType === 9 ? 1 : 0  // FlipVertical uses X axis
                            y: root.animationType === 8 ? 1 : 0  // FlipHorizontal uses Y axis
                            z: (root.animationType === 11 || root.animationType === 14) ? 1 : 0  // Swing/Roll uses Z
                        }
                        angle: 0
                    }
                ]

                states: [
                    State {
                        name: "closed"
                        PropertyChanges {
                            target: container
                            opacity: 0
                        }
                        PropertyChanges {
                            target: scaleTransform
                            xScale: root.animationType === 12 ? 0.8 : container.targetScale
                            yScale: root.animationType === 12 ? 1.2 : container.targetScale
                        }
                        PropertyChanges {
                            target: translateTransform
                            x: container.targetTranslateX
                            y: container.targetTranslateY
                        }
                        PropertyChanges {
                            target: rotationTransform
                            angle: container.targetRotation
                        }
                    },
                    State {
                        name: "open"
                        PropertyChanges {
                            target: container
                            opacity: 1.0
                        }
                        PropertyChanges {
                            target: scaleTransform
                            xScale: 1.0
                            yScale: 1.0
                        }
                        PropertyChanges {
                            target: translateTransform
                            x: 0
                            y: 0
                        }
                        PropertyChanges {
                            target: rotationTransform
                            angle: 0
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "closed"
                        to: "open"
                        SequentialAnimation {
                            ScriptAction {
                                script: root.opened()
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: container
                                    property: "opacity"
                                    duration: root.animationDuration
                                    easing.type: {
                                        switch (root.animationType) {
                                        case 6:  // Bounce
                                        case 12: // RubberBand
                                            return Easing.OutBack;
                                        case 11: // Swing
                                            return Easing.OutElastic;
                                        default:
                                            return root.animationEasing;
                                        }
                                    }
                                }
                                NumberAnimation {
                                    target: scaleTransform
                                    properties: "xScale,yScale"
                                    duration: root.animationDuration
                                    easing.type: {
                                        switch (root.animationType) {
                                        case 6:  // Bounce
                                        case 12: // RubberBand
                                            return Easing.OutBack;
                                        case 11: // Swing
                                            return Easing.OutElastic;
                                        default:
                                            return root.animationEasing;
                                        }
                                    }
                                }
                                NumberAnimation {
                                    target: translateTransform
                                    properties: "x,y"
                                    duration: root.animationDuration
                                    easing.type: {
                                        switch (root.animationType) {
                                        case 6:  // Bounce
                                            return Easing.OutBack;
                                        case 11: // Swing
                                            return Easing.OutElastic;
                                        default:
                                            return root.animationEasing;
                                        }
                                    }
                                }
                                NumberAnimation {
                                    target: rotationTransform
                                    property: "angle"
                                    duration: root.animationType === 11 ? root.animationDuration * 1.5 : root.animationDuration
                                    easing.type: {
                                        switch (root.animationType) {
                                        case 11: // Swing
                                            return Easing.OutElastic;
                                        case 14: // RollIn
                                            return Easing.OutBack;
                                        default:
                                            return root.animationEasing;
                                        }
                                    }
                                }
                            }
                        }
                    },
                    Transition {
                        from: "open"
                        to: "closed"
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: container
                                    property: "opacity"
                                    duration: root.animationDuration
                                    easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    target: scaleTransform
                                    properties: "xScale,yScale"
                                    duration: root.animationDuration
                                    easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    target: translateTransform
                                    properties: "x,y"
                                    duration: root.animationDuration
                                    easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    target: rotationTransform
                                    property: "angle"
                                    duration: root.animationDuration
                                    easing.type: Easing.InCubic
                                }
                            }
                            ScriptAction {
                                script: {
                                    root.closed();
                                    popupLoader.active = false;
                                }
                            }
                        }
                    }
                ]
                
                Loader {
                    id: contentLoader
                    // Position content with margins, let it size naturally
                    x: root.margins
                    y: root.margins
                    sourceComponent: root.contentItem
                    
                    // Trigger animation only when content is fully loaded
                    onStatusChanged: {
                        if (status === Loader.Ready && contentLoader.item) {
                            contentLoader.item.focus = true;
                            // Wait one frame to ensure size is calculated
                            Qt.callLater(() => {
                                if (container.state === "closed") {
                                    container.state = "open";
                                }
                            });
                        }
                    }
                }
            }
        }
    }
}
