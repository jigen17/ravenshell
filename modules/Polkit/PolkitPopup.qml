import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.config
import qs.widgets
import qs.assets
Item {
    id: root

    // Animation settings
    property int animationType: 0
    property int animationDuration: 250
    property int animationEasing: Easing.OutCubic

    // Position settings
    property string anchorPosition: "center"
    property int margins: 20
    property int screenMargin: 8

    // Appearance
    property real backgroundOpacity: 1
    property int cornerRadius: 30

    // Size constraints
    property int contentWidth: 500
    property int contentHeight: 450

    // Behavior
    property bool closeOnEscape: true
    property int hideDelay: 0
    property bool keyboardFocus: true

    // Signals
    signal opened
    signal aboutToOpen

    // Public methods
    function openWindow() {
        aboutToOpen();
        popupLoader.active = true;
    }

    Timer {
        id: autoHideTimer
        interval: root.hideDelay
        running: false
    }

    Loader {
        id: popupLoader
        active: PolkitService.isActive

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

            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: root.keyboardFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

            implicitWidth: root.contentWidth + root.margins * 2
            implicitHeight: root.contentHeight + root.margins * 2

            Rectangle {
                id: container

                anchors.fill: parent
                color: ColorService.colorPalette.backgroundSecondary
                radius: root.cornerRadius
                state: "closed"

                Component.onCompleted: state = "open"

                transformOrigin: Item.Center

                transform: [
                    Scale {
                        id: scaleTransform
                        origin.x: container.width / 2
                        origin.y: root.animationType === 11 ? 0 : container.height / 2
                    },
                    Translate {
                        id: translateTransform
                    },
                    Rotation {
                        id: rotationTransform
                        origin.x: container.width / 2
                        origin.y: container.height / 2
                        axis {
                            x: root.animationType === 9 ? 1 : 0
                            y: root.animationType === 8 ? 1 : 0
                            z: (root.animationType === 11 || root.animationType === 14) ? 1 : 0
                        }
                    }
                ]

                states: [
                    State {
                        name: "closed"
                        PropertyChanges {
                            container.opacity: 0
                            scaleTransform {
                                xScale: getClosedScaleX()
                                yScale: getClosedScaleY()
                            }
                            translateTransform {
                                x: getClosedTranslateX()
                                y: getClosedTranslateY()
                            }
                            rotationTransform.angle: getClosedRotation()
                        }
                    },
                    State {
                        name: "open"
                        PropertyChanges {
                            container.opacity: root.backgroundOpacity
                            scaleTransform {
                                xScale: 1.0
                                yScale: 1.0
                            }
                            translateTransform {
                                x: 0
                                y: 0
                            }
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
                                    root.opened();
                                    if (root.hideDelay > 0)
                                        autoHideTimer.start();
                                }
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: container
                                    property: "opacity"
                                    duration: root.animationDuration
                                    easing.type: getOpenEasing()
                                }
                                NumberAnimation {
                                    target: scaleTransform
                                    properties: "xScale,yScale"
                                    duration: root.animationDuration
                                    easing.type: getOpenEasing()
                                }
                                NumberAnimation {
                                    target: translateTransform
                                    properties: "x,y"
                                    duration: root.animationDuration
                                    easing.type: getOpenEasing()
                                }
                                NumberAnimation {
                                    target: rotationTransform
                                    property: "angle"
                                    duration: root.animationType === 11 ? root.animationDuration * 1.5 : root.animationDuration
                                    easing.type: getRotationEasing()
                                }
                            }
                        }
                    }
                ]

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: root.margins
                    }
                    spacing: Ui.tokens.spacing.lg

                    RavenText {
                        text: "Authentication Required"
                        fontSize: Ui.tokens.fontSize.xl
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RavenText {
                        text: PolkitService.authFlow?.message || ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        Layout.alignment: Text.AlignHCenter
                    }

                    Column {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Ui.tokens.spacing.md

                        ClippingRectangle {
                            width: 80
                            height: 80
                            color: ColorService.colorPalette.accentPrimary
                            radius: width / 2
                            anchors.horizontalCenter: parent.horizontalCenter

                            Image {
                                anchors.fill: parent
                                source: "file:///home/" + PolkitService.authFlow.identities[0].displayName + "/.face.icon"
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        RavenText {
                            text: PolkitService.authFlow.identities[0].displayName || "user"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    RavenText {
                        text: PolkitService.authFlow?.supplementaryMessage || ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: PolkitService.authFlow?.supplementaryIsError ? "red" : ColorService.colorPalette.textSecondary
                        visible: text.length > 0
                    }

                    // Password input
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        radius: 12
                        color: ColorService.colorPalette.backgroundSecondary
                        border.width: 2
                        border.color: passwordInput.activeFocus ? ColorService.colorPalette.accentPrimary : ColorService.colorPalette.backgroundSecondary_300

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                        RowLayout {
                            anchors.fill: parent
                            TextField {
                                id: passwordInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                padding: Ui.tokens.spacing.md
                                placeholderText: PolkitService.authFlow?.inputPrompt || "Password..."
                                placeholderTextColor: ColorService.colorPalette.textSecondary
                                echoMode: showPassword ? TextInput.Normal : TextInput.Password
                                focus: true
                                background: null
                                property bool showPassword: PolkitService.authFlow?.responseVisible || false
                              
                                Component.onCompleted: forceActiveFocus()
                                color: ColorService.colorPalette.textSecondary
                                Keys.onReturnPressed: {
                                    if (passwordInput.text.length > 0) {
                                        PolkitService.authFlow.submit(passwordInput.text);
                                    }
                                }

                                Keys.onEscapePressed: PolkitService.authFlow.cancelAuthenticationRequest()
                            }

                            // Password visibility toggle
                            ButtonIcon {
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 50
                                iconName: passwordInput.showPassword ? Icons.toggles.visibility_on : Icons.toggles.visibility_off
                                onClicked: passwordInput.showPassword = !passwordInput.showPassword
                            }
                        }
                    }

                    // Action buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Ui.tokens.spacing.md

                        // Cancel button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: cancelMouse.containsMouse ? ColorService.colorPalette.backgroundSecondary_300 : ColorService.colorPalette.backgroundSecondary
                            radius: 12
                            border.width: 2
                            border.color: ColorService.colorPalette.backgroundSecondary_300

                            RavenText {
                                anchors.centerIn: parent
                                text: "Cancel"
                                fontSize: Ui.tokens.fontSize.md
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: cancelMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PolkitService.authFlow.cancelAuthenticationRequest()
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        // Authenticate button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: authMouse.containsMouse ? ColorService.colorPalette.accentPrimary_300 : ColorService.colorPalette.accentPrimary
                            opacity: passwordInput.text.length === 0 ? 0.5 : 1.0
                            radius: 12

                            RavenText {
                                anchors.centerIn: parent
                                text: "Authenticate"
                                fontSize: Ui.tokens.fontSize.md
                                font.weight: Font.Medium
                                color: ColorService.colorPalette.backgroundSecondary
                            }

                            MouseArea {
                                id: authMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: passwordInput.text.length > 0
                                onClicked: PolkitService.authFlow.submit(passwordInput.text)
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }
                    }
                }
            }

            // Helper functions for animation states
            function getClosedScaleX() {
                switch (root.animationType) {
                case 0:
                case 6:
                    return 0.9;
                case 7:
                case 10:
                    return 0.0;
                case 12:
                    return 0.8;
                case 13:
                    return 0.95;
                default:
                    return 1.0;
                }
            }

            function getClosedScaleY() {
                switch (root.animationType) {
                case 0:
                case 6:
                    return 0.9;
                case 7:
                case 10:
                    return 0.0;
                case 12:
                    return 1.2;
                case 13:
                    return 0.95;
                default:
                    return 1.0;
                }
            }

            function getClosedTranslateX() {
                if (root.animationType === 3)
                    return 40;
                if (root.animationType === 4 || root.animationType === 10)
                    return -40;
                if (root.anchorPosition === "left")
                    return -40;
                if (root.anchorPosition === "right")
                    return 40;
                return 0;
            }

            function getClosedTranslateY() {
                if (root.animationType === 1)
                    return -40;
                if (root.animationType === 2 || root.animationType === 10)
                    return 40;
                if (root.animationType === 13)
                    return 20;
                if (root.anchorPosition === "top")
                    return -40;
                if (root.anchorPosition === "bottom")
                    return 40;
                return 0;
            }

            function getClosedRotation() {
                if (root.animationType === 8 || root.animationType === 9)
                    return 90;
                if (root.animationType === 11)
                    return -15;
                if (root.animationType === 14)
                    return 360;
                return 0;
            }

            function getOpenEasing() {
                if (root.animationType === 6 || root.animationType === 12)
                    return Easing.OutBack;
                if (root.animationType === 11)
                    return Easing.OutElastic;
                return root.animationEasing;
            }

            function getRotationEasing() {
                if (root.animationType === 11)
                    return Easing.OutElastic;
                if (root.animationType === 14)
                    return Easing.OutBack;
                return root.animationEasing;
            }
        }
    }
}
