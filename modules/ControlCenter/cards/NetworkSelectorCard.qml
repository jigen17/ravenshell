import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.assets
import qs.services
import qs.widgets

Item {
    id: root
    Component.onCompleted: NetworkService.wifiAdapter.scannerEnabled = true;
    function wifiIcon(strength) {
        if (strength > 0.75)
            return Icons.network.wifi.high;
        if (strength > 0.5)
            return Icons.network.wifi.medium;
        if (strength > 0.25)
            return Icons.network.wifi.low;
        return Icons.network.wifi.none;
    }

    function sortedNetworks() {
        if (!NetworkService.wifiAdapter)
            return [];
        return [...NetworkService.wifiAdapter.networks.values].sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.known !== b.known)
                return a.known ? -1 : 1;
            return b.signalStrength - a.signalStrength;
        });
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(ColorService.colorPalette.backgroundSecondary_300.r, ColorService.colorPalette.backgroundSecondary_300.g, ColorService.colorPalette.backgroundSecondary_300.b, 0.2)
        radius: 12
        border {
            width: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.2)
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            RavenText {
                text: "NETWORK"
                opacity: 0.2
            }

            Item { Layout.fillWidth: true }
            RavenToggle {
                checked: NetworkService.wifiEnabled
                onToggled: NetworkService.toggleWifi()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.2)
        }

        ListView {
            id: netList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2

            model: root.sortedNetworks()

            section.property: "known"
            section.criteria: ViewSection.FullString

            section.delegate: Item {
                width: netList.width
                height: 28

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 6
                        rightMargin: 6
                    }
                    spacing: 8

                    RavenText {
                        text: section === "true" ? "KNOWN" : "OTHER NETWORKS"
                        font.pixelSize: 10
                        opacity: 0.25
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.1)
                    }
                }
            }

            delegate: Item {
                required property var modelData

                // ── Only true for the network the user clicked ────────────
                property bool awaitingPassword: false

                width: netList.width
                height: awaitingPassword ? 90 : 54

                Behavior on height {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (awaitingPassword) return;
                        if (modelData.connected) {
                            modelData.disconnect();
                        } else if (modelData.known) {
                            modelData.connect();
                        } else {
                            awaitingPassword = true;
                            passwordField.forceActiveFocus();
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: modelData.connected
                        ? Qt.rgba(ColorService.colorPalette.accentonSecondary.r, ColorService.colorPalette.accentonSecondary.g, ColorService.colorPalette.accentonSecondary.b, 0.12)
                        : mouseArea.containsMouse
                            ? Qt.rgba(ColorService.colorPalette.accentonSecondary.r, ColorService.colorPalette.accentonSecondary.g, ColorService.colorPalette.accentonSecondary.b, 0.06)
                            : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutInSine }
                    }

                    Rectangle {
                        visible: modelData.connected
                        anchors {
                            left: parent.left
                            top: parent.top
                            topMargin: 10
                            bottom: parent.bottom
                            bottomMargin: 10
                        }
                        width: 2
                        radius: 1
                        color: ColorService.colorPalette.accentonSecondary
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 8
                        leftMargin: 14
                    }
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            color: modelData.connected
                                ? Qt.rgba(ColorService.colorPalette.accentonSecondary.r, ColorService.colorPalette.accentonSecondary.g, ColorService.colorPalette.accentonSecondary.b, 0.2)
                                : Qt.rgba(ColorService.colorPalette.backgroundSecondary_300.r, ColorService.colorPalette.backgroundSecondary_300.g, ColorService.colorPalette.backgroundSecondary_300.b, 0.5)

                            RavenIcon {
                                anchors.centerIn: parent
                                iconName: root.wifiIcon(modelData.signalStrength)
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            RavenText {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                opacity: modelData.connected ? 1.0 : 0.75
                            }

                            RavenText {
                                Layout.fillWidth: true
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                opacity: modelData.connected ? 0.65 : 0.35
                                text: {
                                    if (modelData.stateChanging)
                                        return modelData.connected ? "Disconnecting…" : "Connecting…";
                                    const sec = NetworkService.securityType(modelData.security);
                                    if (modelData.connected)
                                        return "Connected · " + sec;
                                    if (modelData.known)
                                        return "Saved · " + sec;
                                    return sec || "Open";
                                }
                            }
                        }
                    }

                    // ── Password row — only for this delegate when awaiting ─
                    RowLayout {
                        Layout.fillWidth: true
                        visible: awaitingPassword
                        spacing: 6

                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            placeholderText: "Password"
                            echoMode: TextInput.Password

                            Keys.onReturnPressed: {
                                Quickshell.execDetached(["nmcli", "device", "wifi", "connect", modelData.name, "password", text]);
                                awaitingPassword = false;
                                text = "";
                            }

                            Keys.onEscapePressed: {
                                awaitingPassword = false;
                                text = "";
                            }
                        }
                    }
                }
            }
        }
    }
}
