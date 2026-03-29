import QtQuick
import qs.services

Item {
    id: root

    // Public properties
    property bool checked: false
    property color onColor: ColorService.colorPalette.accentonPrimary
    property color offColor: ColorService.colorPalette.backgroundPrimary
    property color knobOnColor: "white"
    property color knobOffColor: ColorService.colorPalette.backgroundSecondary_100
    property color rippleColor: root.checked ? Qt.lighter(onColor, 1.3) : Qt.darker(offColor, 1.2)
    property int animationDuration: 250
    property bool enabled: true

    signal toggled()

    implicitWidth: 36
    implicitHeight: 20
    opacity: enabled ? 1 : 0.38
    // Accessibility
    Accessible.role: Accessible.CheckBox
    Accessible.name: "Toggle switch"
    Accessible.checkable: true
    Accessible.checked: root.checked
    Accessible.onPressAction: {
        if (root.enabled) {
            root.checked = !root.checked;
            root.toggled();
        }
    }

    // Track (background)
    Rectangle {
        id: track

        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.onColor : root.offColor
        border.width: root.checked ? 0 : 1.5
        border.color: ColorService.colorPalette.backgroundSecondary_300

        Behavior on color {
            ColorAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }

        }

        Behavior on border.width {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }

        }

    }

    // Knob container for positioning
    Item {
        id: knobContainer

        anchors.fill: parent
        // Press state - knob scale
        scale: mouseArea.pressed ? 0.95 : 1

        // Ripple effect background
        Rectangle {
            id: ripple

            width: 28
            height: 28
            radius: 14
            color: root.rippleColor
            opacity: 0
            x: root.checked ? (parent.width - 10 - width / 2) : (10 - width / 2)
            y: (parent.height - height) / 2

            // Ripple animation
            SequentialAnimation {
                id: rippleAnimation

                ParallelAnimation {
                    NumberAnimation {
                        target: ripple
                        property: "opacity"
                        to: 0.16
                        duration: 150
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        target: ripple
                        property: "scale"
                        to: 1.1
                        duration: 150
                        easing.type: Easing.OutQuad
                    }

                }

                ParallelAnimation {
                    NumberAnimation {
                        target: ripple
                        property: "opacity"
                        to: 0
                        duration: 300
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        target: ripple
                        property: "scale"
                        to: 1
                        duration: 300
                        easing.type: Easing.OutQuad
                    }

                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Knob (thumb)
        Rectangle {
            id: knob

            width: root.checked ? 16 : 12
            height: root.checked ? 16 : 12
            radius: width / 2
            color: root.checked ? root.knobOnColor : root.knobOffColor
            // Knob position from edge
            x: root.checked ? (parent.width - width - 2) : 2
            y: (parent.height - height) / 2

            Behavior on x {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on width {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on height {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }

            }

        }

        // Hover state indicator
        Rectangle {
            id: hoverIndicator

            width: 28
            height: 28
            radius: 14
            color: root.rippleColor
            opacity: mouseArea.containsMouse && !mouseArea.pressed ? 0.08 : 0
            x: root.checked ? (parent.width - 10 - width / 2) : (10 - width / 2)
            y: (parent.height - height) / 2

            Behavior on x {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }

            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }

        }

    }

    // Interactive area
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true
        enabled: root.enabled
        onClicked: {
            if (!root.enabled)
                return ;

            root.checked = !root.checked;
            rippleAnimation.restart();
            root.toggled();
            // Haptic feedback simulation (visual only)
            hapticPulse.start();
        }

        // Subtle press animation
        SequentialAnimation {
            id: hapticPulse

            NumberAnimation {
                target: knob
                property: "scale"
                to: 1.15
                duration: 80
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: knob
                property: "scale"
                to: 1
                duration: 120
                easing.type: Easing.OutBack
                easing.overshoot: 2
            }

        }

    }

}
