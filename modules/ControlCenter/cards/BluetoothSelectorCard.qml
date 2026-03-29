import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.assets
import qs.services
import qs.widgets

Item {
    id: root

    // Maps BlueZ icon string to a RavenIcon name
    function btIcon(iconStr) {
        if (iconStr.includes("headset") || iconStr.includes("headphone"))
            return Icons.devices.headphones;
        if (iconStr.includes("keyboard"))
            return Icons.devices.keyboard;
        if (iconStr.includes("mouse"))
            return Icons.devices.mouse;
        if (iconStr.includes("phone"))
            return Icons.devices.phone;
        if (iconStr.includes("audio"))
            return Icons.devices.speaker;
        if (iconStr.includes("computer"))
            return Icons.devices.computer;
        if (iconStr.includes("gamepad") || iconStr.includes("joystick"))
            return Icons.devices.gamepad;
        return Icons.devices.general;
    }

    // Sorted model: connected first → paired → unknown, each group by name
    function sortedDevices() {
        if (!BluetoothService.selectedAdapter)
            return [];
        return [...BluetoothService.devices].sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            return a.name.localeCompare(b.name);
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

        // ── Header ────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            RavenText {
                text: "BLUETOOTH"
                opacity: 0.2
            }

            Item {
                Layout.fillWidth: true
            }

ButtonIcon {
    id: scanButton
    iconName: Icons.power.reboot
    transformOrigin: Item.Center

    onClicked: BluetoothService.scanToggle()

    SequentialAnimation on rotation {
        running: BluetoothService.selectedAdapter?.discovering ?? false
        loops: Animation.Infinite

        NumberAnimation {
            from: 0
            to: 360
            duration: 900
            easing.type: Easing.InOutSine
        }
    }

    SequentialAnimation on scale {
        running: BluetoothService.selectedAdapter?.discovering ?? false
        loops: Animation.Infinite

        NumberAnimation {
            to: 1.1
            duration: 600
            easing.type: Easing.InOutElastic
        }

    }
}

            RavenToggle {
                checked: BluetoothService.bluetoothEnabled
                onToggled: BluetoothService.toggleBluetooth()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.2)
        }

        // ── Device list ───────────────────────────────────────────────────
        ListView {
            id: deviceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2

            model: root.sortedDevices()

            // paired = true  → "PAIRED DEVICES"
            // paired = false → "OTHER DEVICES"
            section.property: "paired"
            section.criteria: ViewSection.FullString

            // ── Section header ────────────────────────────────────────────
            section.delegate: Item {
                width: deviceList.width
                height: 28

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 6
                        rightMargin: 6
                    }
                    spacing: 8

                    RavenText {
                        text: section === "true" ? "PAIRED" : "OTHER DEVICES"
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

            // ── Device row ────────────────────────────────────────────────
            delegate: Item {
                required property var modelData
                width: deviceList.width
                height: 54

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.connected)
                            modelData.disconnect();
                        else if (modelData.paired)
                            modelData.connect();
                        else
                            modelData.pair();
                    }
                }

                // Row background
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: modelData.connected ? Qt.rgba(ColorService.colorPalette.accentonSecondary.r, ColorService.colorPalette.accentonSecondary.g, ColorService.colorPalette.accentonSecondary.b, 0.12) : mouseArea.containsMouse ? Qt.rgba(ColorService.colorPalette.accentonSecondary.r, ColorService.colorPalette.accentonSecondary.g, ColorService.colorPalette.accentonSecondary.b, 0.06) : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutInSine
                        }
                    }

                    // Active left-edge accent
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

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 8
                        leftMargin: 14
                    }
                    spacing: 10

                    // ── Device icon ───────────────────────────────────────
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 8
                        color: modelData.connected ? Qt.rgba(ColorService.colorPalette.accentonSecondary.r, ColorService.colorPalette.accentonSecondary.g, ColorService.colorPalette.accentonSecondary.b, 0.2) : Qt.rgba(ColorService.colorPalette.backgroundSecondary_300.r, ColorService.colorPalette.backgroundSecondary_300.g, ColorService.colorPalette.backgroundSecondary_300.b, 0.5)

                        RavenIcon {
                            anchors.centerIn: parent
                            iconName: root.btIcon(modelData.icon)
                            Component.onCompleted: console.log("first name:", modelData.icon, " second icon name", root.btIcon(modelData.icon))
                        }
                    }

                    // ── Name + status ─────────────────────────────────────
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
                                if (modelData.pairing)
                                    return "Pairing…";
                                if (modelData.connected) {
                                    const bat = modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "%" : "";
                                    return "Connected" + bat;
                                }
                                if (modelData.paired)
                                    return "Paired · Not connected";
                                return "Not paired";
                            }
                        }
                    }

                    // ── Battery / pairing spinner ─────────────────────────
                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        // Battery bars — only when connected and battery available
                        Item {
                            visible: modelData.connected && modelData.batteryAvailable && !modelData.pairing
                            anchors.centerIn: parent
                            width: 18
                            height: 14

                            Repeater {
                                model: 4
                                delegate: Rectangle {
                                    required property int index
                                    width: 3
                                    height: 3 + index * 3
                                    x: index * 5
                                    y: parent.height - height
                                    radius: 1
                                    color: ColorService.colorPalette.accentonSecondary
                                    opacity: (modelData.battery * 4) > index ? 1.0 : 0.12
                                }
                            }
                        }

                        // Pairing spinner
                        BusyIndicator {
                            visible: modelData.pairing
                            running: modelData.pairing
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                        }
                    }
                }
            }
        }
    }
}
