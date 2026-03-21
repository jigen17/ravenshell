import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: ColorService.colorPalette.backgroundSecondary
        radius: 18
    }
    readonly property var iconMap: ({
            "audio-headphones": Icons.devices.headphones,
            "audio-headset": Icons.devices.headphones,
            "audio-card": Icons.devices.speaker,
            "computer": Icons.devices.computer,
            "phone": Icons.devices.phone,
            "": Icons.devices.general
        })

    readonly property var batteryMap: [Icons.battery.empty, Icons.battery.low, Icons.battery.medium, Icons.battery.high, Icons.battery.full]

    function batteryIcon(value) {
        return batteryMap[Math.min(4, Math.floor(value * 5))];
    }

    ColumnLayout {
        spacing: 10

        anchors {
            fill: parent
            margins: 20
        }

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            RavenText {
                text: "Bluetooth Devices"
                fontSize: Ui.tokens.fontSize.md
                font.weight: Font.Bold
            }

            Item {
                Layout.fillWidth: true
            }

            RavenToggle {
                checked: BluetoothService.bluetoothEnabled
                onToggled: BluetoothService.toggleBluetooth()
                implicitWidth: 40
                implicitHeight: 25
            }

            ButtonIcon {
                id: scanButton
                iconName: Icons.utilities.hourglass
                iconSize: 22
                buttonPadding: 5
                backgroundColor: ColorService.colorPalette.accentTertiary                          
                opacity: BluetoothService.bluetoothEnabled ? 1.0 : 0.5

                Behavior on opacity {
                  NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutCubic
                  }
                }
                onClicked: BluetoothService.scanToggle()

                // Smooth rotation
                RotationAnimator {
                    target: scanButton
                    running: BluetoothService.selectedAdapter?.discovering ?? false
                    from: 0
                    to: 360
                    duration: 1400
                    loops: Animation.Infinite
                    easing.type: Easing.InOutCubic
                }

                // Pulse animation
                SequentialAnimation on scale {
                    running: BluetoothService.selectedAdapter?.discovering ?? false
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 1.1
                        duration: 700
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: 1.0
                        duration: 700
                        easing.type: Easing.InOutQuad
                    }
                }

                onVisibleChanged: if (!visible) {
                    rotation = 0;
                    scale = 1.0;
                }

                Connections {
                    target: BluetoothService.selectedAdapter
                    function onDiscoveringChanged() {
                        if (!BluetoothService.selectedAdapter.discovering) {
                            scanButton.rotation = 0;
                            scanButton.scale = 1.0;
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: ColorService.colorPalette.backgroundSecondary_300
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                height: parent.height
                spacing: 16

                // Connected Device Section
                ColumnLayout {
                    visible: BluetoothService.connectedDevice !== null
                    Layout.fillWidth: true
                    spacing: 8

                    RavenText {
                        text: "Connected"
                        fontSize: Ui.tokens.fontSize.sm
                        opacity: 0.7
                        font.weight: Font.Medium
                    }

                    ConnectedDevice {
                        Layout.fillWidth: true
                        device: BluetoothService.connectedDevice
                        visible: BluetoothService.connectedDevice !== null
                    }
                }

                // Paired Devices Section (not connected)
                ColumnLayout {
                    visible: BluetoothService.pairedDevices.length > 0
                    Layout.fillWidth: true
                    spacing: 8

                    RavenText {
                        text: "My Devices"
                        fontSize: Ui.tokens.fontSize.sm
                        opacity: 0.7
                        font.weight: Font.Medium
                    }

                    Repeater {
                        model: BluetoothService.pairedDevices

                        PairedDevice {
                            required property var modelData

                            Layout.fillWidth: true
                            device: modelData
                        }
                    }
                }

                // Unknown Devices Section (not paired)
                ColumnLayout {
                    visible: BluetoothService.unknownDevices.length > 0
                    Layout.fillWidth: true
                    spacing: 8

                    RavenText {
                        text: "Available Devices"
                        fontSize: Ui.tokens.fontSize.xs
                        opacity: 0.7
                        font.weight: Font.Medium
                    }

                    Repeater {
                        model: BluetoothService.unknownDevices

                        UnknownDevice {
                            required property var modelData

                            Layout.fillWidth: true
                            device: modelData
                        }
                    }
                }

                // Empty State
                ColumnLayout {
                    visible: BluetoothService.devices.length === 0 && BluetoothService.bluetoothEnabled
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    Item {
                        Layout.fillHeight: true
                    }

                    RavenIcon {
                        Layout.alignment: Qt.AlignHCenter
                        iconName: Icons.bluetooth.enabled
                        iconSize: 48
                        opacity: 0.3
                    }

                    RavenText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No devices found"
                        fontSize: Ui.tokens.fontSize.sm
                        opacity: 0.5
                    }

                    RavenText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Make sure your device is in pairing mode"
                        fontSize: Ui.tokens.fontSize.xs
                        opacity: 0.4
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }

                // Disabled State
                ColumnLayout {
                    visible: !BluetoothService.bluetoothEnabled
                    Layout.alignment: Qt.AlignCenter
                    spacing: 12

                    Item {
                        Layout.fillHeight: true
                    }

                    RavenIcon {
                        Layout.alignment: Qt.AlignHCenter
                        iconName: Icons.bluetooth.off
                        iconSize: 48
                        opacity: 0.3
                    }

                    RavenText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Bluetooth is disabled"
                        fontSize: Ui.tokens.fontSize.sm
                        opacity: 0.5
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }

    // Connected Device Component
    component ConnectedDevice: Rectangle {
        required property var device

        color: ColorService.colorPalette.backgroundSecondary_300
        radius: 16
        implicitHeight: 50
        visible: device !== null

        RowLayout {
            spacing: 12

            anchors {
                fill: parent
                leftMargin: 15
                rightMargin: 15
            }

            // Device Icon
            RavenIcon {
                iconName: iconMap[device?.icon] ?? Icons.devices.general
                iconSize: 28
            }

            // Device Info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RavenText {
                    text: device ? (device.name || device.deviceName || "Unknown") : "Unknown"
                    fontSize: Ui.tokens.fontSize.sm
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                RowLayout {
                    spacing: 10
                    RavenText {
                        text: device && device.connected ? "Connected" : "Disconnected"
                        fontSize: Ui.tokens.fontSize.xs
                        opacity: 0.7
                    }
                    RavenIcon {
                        iconName: Icons.utilities.agreement
                        opacity: 0.7
                    }
                    // Battery indicator
                    RowLayout {
                        RavenIcon {
                            iconName: root.batteryIcon(device?.battery)
                            opacity: 0.7
                        }
                        RavenText {
                            visible: device && device.batteryAvailable
                            text: device && device.batteryAvailable ? `${Math.round(device.battery * 100)}%` : ""
                            fontSize: Ui.tokens.fontSize.xs
                            opacity: 0.7
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            RowLayout {
                // Disconnect Button
                spacing: 15
                ButtonIcon {
                    iconName: Icons.utilities.link_break
                    iconSize: 20
                    buttonPadding: 5
                    enabled: device !== null
                    onClicked: {
                        if (device)
                            device.disconnect();
                    }
                }

                // Forget Button
                ButtonIcon {
                    iconName: Icons.utilities.eraser
                    iconSize: 20
                    buttonPadding: 5
                    enabled: device !== null
                    onClicked: {
                        if (device)
                            device.forget();
                    }
                }
            }
        }
    }

    // Paired Device Component (not connected)
    component PairedDevice: Rectangle {
        required property var device

        color: ColorService.colorPalette.backgroundSecondary_300
        radius: 16
        implicitHeight: 50

        RowLayout {
            spacing: 12

            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 12
            }

            RavenIcon {
                iconName: iconMap[device.icon] || Icons.device.general
                iconSize: 28
            }

            // Device Info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RavenText {
                    text: device.name || device.deviceName || "Unknown Device"
                    fontSize: Ui.tokens.fontSize.sm
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                RavenText {
                    text: device.trusted ? "Trusted" : "Paired"
                    fontSize: Ui.tokens.fontSize.xs
                    opacity: 0.6
                }
            }

            // Connect Button
            ButtonIcon {
                iconName: Icons.utilities.link
                iconSize: 16
                buttonPadding: 8
                backgroundColor: ColorService.colorPalette.accentTertiary
                onClicked: {
                    if (device)
                        device.connect();
                }
            }

            // Forget Button
            ButtonIcon {
                iconName: Icons.utilities.eraser
                iconSize: 16
                buttonPadding: 8
                backgroundColor: ColorService.colorPalette.backgroundSecondary_100
                onClicked: {
                    if (device)
                        device.forget();
                }
            }
        }
    }

    // Unknown Device Component (not paired)
    component UnknownDevice: Rectangle {
        required property var device

        color: ColorService.colorPalette.backgroundSecondary_300
        radius: 16
        implicitHeight: 50

        RowLayout {
            spacing: 12

            anchors {
                fill: parent
                leftMargin: 15
                rightMargin: 15
            }

            RavenIcon {
                iconName: iconMap[device.icon] || Icons.devices.general
                iconSize: 28
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RavenText {
                    text: device.deviceName || "Unknown Device"
                    fontSize: Ui.tokens.fontSize.sm
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                RavenText {
                    text: device.address || ""
                    fontSize: Ui.tokens.fontSize.xs
                    opacity: 0.5
                    font.family: "monospace"
                }
            }

            Loader {
                sourceComponent: device && device.pairing ? pairingIndicator : pairButton
            }

            Component {
                id: pairingIndicator

                RowLayout {
                    spacing: 8

                    BusyIndicator {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        running: true
                    }

                    ButtonIcon {
                        iconName: Icons.utilities.dismiss_circle
                        iconSize: 16
                        buttonPadding: 8
                        backgroundColor: ColorService.colorPalette.backgroundSecondary_100
                        onClicked: {
                            if (device) {
                                console.log("Cancelling pair for:", device.deviceName);
                                device.cancelPair();
                            }
                        }
                    }
                }
            }

            Component {
                id: pairButton

                RavenTextButton {
                    text: "Pair"
                    buttonPadding: 10
                    radius: 10
                    backgroundColor: ColorService.colorPalette.accentTertiary
                    onClicked: {
                        if (!device)
                            return;

                        console.log("=== PAIR BUTTON CLICKED ===");
                        console.log("  Device:", device.deviceName);
                        console.log("  Address:", device.address);
                        console.log("  Initial paired:", device.paired);
                        console.log("  Initial pairing:", device.pairing);
                        console.log("  Initial connected:", device.connected);
                        console.log("  Initial bonded:", device.bonded);
                        console.log("  Initial state:", device.state);
                        console.log("  Adapter ", device.adapter);
                        console.log("  Calling device.pair()...");
                        console.log("=== PAIR BUTTON CLICKED ===");
                        console.log("  Setting trusted FIRST...");
                        device.trusted = true;
                        device.blocked = false;
                        console.log("  Now calling device.pair()...");
                        device.pair();
                    }
                }
            }
        }
    }
}
