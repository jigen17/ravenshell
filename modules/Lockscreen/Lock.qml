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
                    Qt.callLater( () => {
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
                    color: ColorService.colorPalette.backgroundPrimary

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: Ui.tokens.spacing.md
                        color: ColorService.colorPalette.backgroundPrimary
                        radius: 18

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

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: Qt.rgba(0, 0, 0, 0.2)
                                }
                                GradientStop {
                                    position: 1.0
                                    color: Qt.rgba(0, 0, 0, 0.4)
                                }
                            }
                        }

                        // Center content
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0

                            // Time
                            RavenText {
                                text: TimeService.timeString
                                font.family: "Nunito Heavy"
                                fontSize: 120
                                Layout.alignment: Qt.AlignHCenter
                                Layout.bottomMargin: -20
                                horizontalAlignment: Qt.AlignHCenter
                                color: ColorService.colorPalette.backgroundPrimary
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: "#80000000"
                                    shadowBlur: 0.5
                                    shadowHorizontalOffset: 2
                                    shadowVerticalOffset: 2
                                }
                            }

                            // Date
                            RavenText {
                                text: TimeService.dateStringLarge
                                font.family: "Nunito Heavy"
                                fontSize: 30
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Qt.AlignHCenter
                                color: ColorService.colorPalette.backgroundPrimary
                                opacity: 0.9
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: "#60000000"
                                    shadowBlur: 0.4
                                    shadowHorizontalOffset: 1
                                    shadowVerticalOffset: 1
                                }
                            }

                            // Password Input Container
                            Item {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 50
                                implicitWidth: 460
                                implicitHeight: 80

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
                                    visible: errorText.text !== ""

                                    Text {
                                        id: errorText
                                        anchors.centerIn: parent
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: 14
                                        text: pamAuth.lastError
                                    }
                                    
                                    // Trigger shake when error appears
                                    onVisibleChanged: {
                                        if (visible) {
                                            shakeAnimation.running = true;
                                        }
                                    }
                                }

                                // Password input box
                                Rectangle {
                                    id: passwordContainer
                                    implicitHeight: 60
                                    implicitWidth: parent.width
                                    color: Qt.rgba(
                                        ColorService.colorPalette.backgroundPrimary.r,
                                        ColorService.colorPalette.backgroundPrimary.g,
                                        ColorService.colorPalette.backgroundPrimary.b,
                                        0.8
                                    )
                                    radius: height / 2
                                    border.color: {
                                        if (pamAuth.isLocked)
                                            return "#ff6b6b";
                                        if (passwordField.activeFocus)
                                            return ColorService.colorPalette.accentonPrimary;
                                        return Qt.rgba(1, 1, 1, 0.2);
                                    }
                                    border.width: 2

                                    Behavior on border.color {
                                        ColorAnimation { duration: 200 }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 20
                                        anchors.rightMargin: 10
                                        spacing: 10

                                        TextField {
                                            id: passwordField
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            enabled: !pamAuth.isLocked && !pamAuth.sessionActive
                                            placeholderText: pamAuth.isLocked 
                                                ? "Locked for " + pamAuth.lockoutMinutes + " minutes" 
                                                : "Enter password"
                                            placeholderTextColor: color
                                            echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                            font.family: "Nunito"
                                            font.pixelSize: 22
                                            horizontalAlignment: Qt.AlignLeft
                                            color: ColorService.colorPalette.accentPrimary

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
                                            iconName: checked ? Icons.toggles.visibility_on : Icons.toggles.visibility_off
                                            onClicked: checked = !checked
                                            enabledColor: "transparent"
                                            visible: passwordField.text.length > 0
                                        }

                                        // Busy spinner / unlock button
                                        Item {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40

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
                                                backgroundColor: ColorService.colorPalette.accentPrimary
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
                        }

                        // Power buttons
                        ColumnLayout {
                            anchors {
                                bottom: parent.bottom
                                right: parent.right
                                bottomMargin: Ui.tokens.spacing.md * 2
                                rightMargin: Ui.tokens.spacing.md * 2
                            }
                            spacing: Ui.tokens.spacing.sm

                            ButtonIcon {
                                iconName: Icons.power.logout
                                iconColor: ColorService.colorPalette.backgroundSecondary
                                buttonPadding: Ui.tokens.spacing.md
                                backgroundColor: ColorService.colorPalette.accentonPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            ButtonIcon {
                                iconName: Icons.power.reboot
                                iconColor: ColorService.colorPalette.backgroundSecondary
                                buttonPadding: Ui.tokens.spacing.md
                                backgroundColor: ColorService.colorPalette.accentonPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            ButtonIcon {
                                iconName: Icons.power.shutdown
                                iconColor: ColorService.colorPalette.backgroundSecondary
                                buttonPadding: Ui.tokens.spacing.md
                                backgroundColor: ColorService.colorPalette.accentonPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Media player
                        Rectangle {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                                bottomMargin: Ui.tokens.spacing.md * 2
                            }
                            color: Qt.rgba(
                                ColorService.colorPalette.accentonPrimary.r,
                                ColorService.colorPalette.accentonPrimary.g,
                                ColorService.colorPalette.accentonPrimary.b,
                                0.85
                            )
                            implicitWidth: 300
                            implicitHeight: 100
                            radius: 60
                            border.color: Qt.rgba(1, 1, 1, 0.15)
                            border.width: 1
                            visible: MprisService.activePlayer !== null

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 2

                                ClippingRectangle {
                                    Layout.alignment: Qt.AlignHCenter
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
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Row {
                                    Layout.rightMargin: Ui.tokens.spacing.md
                                    spacing: Ui.tokens.spacing.md

                                    ButtonIcon {
                                        iconName: Icons.player.previous
                                        iconColor: ColorService.colorPalette.backgroundPrimary
                                        onClicked: MprisService.previousTrack()
                                    }
                                    ButtonIcon {
                                        iconName: MprisService.activePlayer?.isPlaying ? Icons.player.pause : Icons.player.play
                                        iconColor: ColorService.colorPalette.backgroundPrimary
                                        onClicked: MprisService.toggleTrack()
                                    }
                                    ButtonIcon {
                                        iconName: Icons.player.next
                                        iconColor: ColorService.colorPalette.backgroundPrimary
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
}
