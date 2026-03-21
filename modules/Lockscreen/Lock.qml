import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    KeyboardShortcut {
        name: "lockScreen"
        onPressed: {
            lockloader.active = true;
            console.log("Lock toggle pressed");
        }
    }

    IpcHandler {
        target: "lockScreen"
        function lock() {
            lockloader.active = true;
        }
    }

    Loader {
        id: lockloader
        active: false

        sourceComponent: Item {
            id: lockItem

            // PAM Authentication
            PamAuth {
                id: pamAuth
                property string lastError: ""

                onUnlocked: {
                    console.log(">>> UNLOCKED SIGNAL RECEIVED <<<");
                    lastError = "";
                    locker.locked = false;
                    console.log(">>> Setting locker.locked to false <<<");
                    Qt.callLater(() => {
                        lockloader.active = false;
                    });
                }

                onPamError: message => {
                    console.log(">>> PAM ERROR SIGNAL RECEIVED:", message);
                    lastError = message;
                }
            }

            Component.onCompleted: {
                console.log(">>> Lock component loaded, setting locker.locked = true <<<");
                locker.locked = true;
            }

            WlSessionLock {
                id: locker

                WlSessionLockSurface {
                    id: lockerSurface

                    property color cachedBgColor: ColorService.colorPalette.backgroundPrimary
                    property color cachedAccentColor: ColorService.colorPalette.accentPrimary
                    property color cachedAccentOnColor: ColorService.colorPalette.accentonPrimary

                    color: cachedBgColor

                    // LAYER 1: Background (static, render once)
                    ClippingRectangle {
                        id: backgroundLayer
                        anchors.fill: parent
                        anchors.margins: Ui.tokens.spacing.md
                        color: lockerSurface.cachedBgColor
                        radius: 18

                        // Isolate background rendering - renders once and caches
                        layer.enabled: true
                        layer.smooth: true

                        // Background with blur
                        Image {
                            id: backgroundImage
                            anchors.fill: parent
                            source: Settings.config.wallpapers.path
                            smooth: true
                            cache: true
                        }

                        MultiEffect {
                            anchors.fill: parent
                            source: backgroundImage
                            blurEnabled: true
                            blur: 1.0
                            blurMax: 32
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.25
                        spacing: -20

                        RavenText {
                            text: TimeService.timeString
                             font.family: Settings.config.fonts.heavyFont
                             font.bold: true
                            fontSize: 120
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: lockerSurface.cachedBgColor
                            style: Text.Raised
                            styleColor: "#80000000"
                        }

                        RavenText {
                            text: TimeService.dateStringLarge
                            font.family: Settings.config.fonts.heavyFont
                            font.bold: true
                            fontSize: 30
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: lockerSurface.cachedBgColor
                            opacity: 0.9
                            style: Text.Raised
                            styleColor: "#60000000"
                        }
                    }

                    // LAYER 3: Password Input (updates on typing)
                    Item {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 80
                        width: 460
                        height: 150

                        // Shake animation
                        SequentialAnimation {
                            id: shakeAnimation
                            running: false

                            NumberAnimation {
                                target: passwordContainer
                                property: "x"
                                to: passwordContainer.x - 10
                                duration: 50
                            }
                            NumberAnimation {
                                target: passwordContainer
                                property: "x"
                                to: passwordContainer.x + 10
                                duration: 50
                            }
                            NumberAnimation {
                                target: passwordContainer
                                property: "x"
                                to: passwordContainer.x - 10
                                duration: 50
                            }
                            NumberAnimation {
                                target: passwordContainer
                                property: "x"
                                to: passwordContainer.x
                                duration: 50
                            }
                        }

                        // Error overlay
                        Rectangle {
                            id: errorOverlay
                            width: passwordContainer.width
                            height: 40
                            radius: 8
                            color: "#ff6b6b"
                            anchors.horizontalCenter: passwordContainer.horizontalCenter
                            anchors.bottom: passwordContainer.top
                            anchors.bottomMargin: 8
                            visible: pamAuth.lastError !== ""

                            Text {
                                id: errorText
                                anchors.centerIn: parent
                                color: "white"
                                font.bold: true
                                font.pixelSize: 14
                                text: pamAuth.lastError
                            }

                            onVisibleChanged: {
                                if (visible) {
                                    shakeAnimation.running = true;
                                }
                            }
                        }

                        // Password input box - ISOLATED to prevent propagation
                        Rectangle {
                            id: passwordContainer
                            implicitHeight: 60
                            implicitWidth: parent.width
                            anchors.centerIn: parent

                            property color containerColor: Qt.rgba(lockerSurface.cachedBgColor.r, lockerSurface.cachedBgColor.g, lockerSurface.cachedBgColor.b, 0.8)

                            color: containerColor
                            radius: height / 2

                            property color borderColorValue: {
                                if (pamAuth.isLocked)
                                    return "#ff6b6b";
                                if (passwordField.activeFocus)
                                    return lockerSurface.cachedAccentOnColor;
                                return Qt.rgba(1, 1, 1, 0.2);
                            }

                            border.color: borderColorValue
                            border.width: 2

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }


                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 10
                                spacing: 10

                                TextField {
                                    id: passwordField
                                    implicitWidth: parent.width - showPasswordButton.width - unlockButtonContainer.width - 30
                                    implicitHeight: parent.height
                                    enabled: !pamAuth.isLocked && !pamAuth.sessionActive
                                    placeholderText: pamAuth.isLocked ? "Locked for " + pamAuth.lockoutMinutes + " minutes" : "Enter password"
                                    placeholderTextColor: color
                                    echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                    passwordCharacter: "●"
                                    font.family: Setting.config.fonts.primary
                                    font.pixelSize:  Ui.tokens.fontSize.lg
                                    horizontalAlignment: Qt.AlignLeft
                                    color: lockerSurface.cachedAccentColor



                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    Component.onCompleted: forceActiveFocus()

                                    onTextChanged: {
                                        pamAuth.responseText = text;
                                        pamAuth.lastError = "";
                                    }

                                    Keys.onReturnPressed: {
                                        if (text !== "" && !pamAuth.sessionActive && !pamAuth.isLocked) {
                                            pamAuth.unlock();
                                        }
                                    }

                                    Keys.onEscapePressed: text = ""
                                }

                                ButtonIcon {
                                    id: showPasswordButton
                                    property bool checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    iconName: checked ? Icons.toggles.visibility_on : Icons.toggles.visibility_off
                                    onClicked: checked = !checked
                                    enabledColor: "transparent"
                                }

                                Item {
                                    id: unlockButtonContainer
                                    width: 40
                                    height: 40
                                    anchors.verticalCenter: parent.verticalCenter

                                    BusyIndicator {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: parent.height
                                        running: pamAuth.sessionActive
                                        visible: pamAuth.sessionActive
                                    }

                                    ButtonIcon {
                                        id: unlockButton
                                        anchors.centerIn: parent
                                        height: parent.height
                                        width: height
                                        visible: !pamAuth.sessionActive
                                        enabled: passwordField.text !== "" && !pamAuth.isLocked
                                        backgroundColor: lockerSurface.cachedAccentColor
                                        radius: height / 2
                                        iconName: Icons.arrows.bendDownLeft
                                        onClicked: {
                                            if (enabled) {
                                                pamAuth.unlock();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            bottomMargin: Ui.tokens.spacing.md * 2
                            rightMargin: Ui.tokens.spacing.md * 2
                        }
                        spacing: Ui.tokens.spacing.sm

                        // Isolate - renders once and caches

                        ButtonIcon {
                            iconName: Icons.power.logout
                            iconColor: lockerSurface.cachedBgColor
                            buttonPadding: Ui.tokens.spacing.md
                            backgroundColor: lockerSurface.cachedAccentOnColor
                            onClicked: SessionService.logout()
                        }
                        ButtonIcon {
                            iconName: Icons.power.reboot
                            iconColor: lockerSurface.cachedBgColor
                            buttonPadding: Ui.tokens.spacing.md
                            backgroundColor: lockerSurface.cachedAccentOnColor
                            onClicked: SessionService.reboot()
                        }
                        ButtonIcon {
                            iconName: Icons.power.shutdown
                            iconColor: lockerSurface.cachedBgColor
                            buttonPadding: Ui.tokens.spacing.md
                            backgroundColor: lockerSurface.cachedAccentOnColor
                            onClicked: SessionService.poweroff()
                        }
                    }

                    // LAYER 5: Media player (updates only on track change)
                    Rectangle {
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                            bottomMargin: Ui.tokens.spacing.md * 2
                        }

                        color: Qt.rgba(ColorService.colorPalette.accentonPrimary.r, ColorService.colorPalette.accentonPrimary.g, ColorService.colorPalette.accentonPrimary.b, 0.85)

                        implicitWidth: 300
                        implicitHeight: 100
                        radius: 60
                        border.color: Qt.rgba(1, 1, 1, 0.15)
                        border.width: 1

                        // Isolate - only redraws on track/play state change
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2

                            ClippingRectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 80
                                implicitHeight: 80
                                radius: 40
                                clip: true
                                border.color: Qt.rgba(1, 1, 1, 0.2)
                                border.width: 2

                                Image {
                                    anchors.fill: parent
                                    source: MprisService.activePlayer?.trackArtUrl ?? ""
                                    fillMode: Image.PreserveAspectCrop
                                    cache: true
                                }
                            }

                            Row {
                                id: playerControls
                                Layout.alignment: Qt.AlignRight
                                Layout.rightMargin: 20
                                spacing: Ui.tokens.spacing.md

                                ButtonIcon {
                                    iconName: Icons.player.previous
                                    iconColor: lockerSurface.cachedBgColor
                                    onClicked: MprisService.previousTrack()
                                }
                                ButtonIcon {
                                    iconName: MprisService.activePlayer?.isPlaying ? Icons.player.pause : Icons.player.play
                                    iconColor: lockerSurface.cachedBgColor
                                    onClicked: MprisService.toggleTrack()
                                }
                                ButtonIcon {
                                    iconName: Icons.player.next
                                    iconColor: lockerSurface.cachedBgColor
                                    onClicked: MprisService.nextTrack()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
