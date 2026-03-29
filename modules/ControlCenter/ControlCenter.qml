import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "cards"
import qs.assets
import qs.config
import qs.services
import qs.widgets

StyledPanel {
    id: root

    property int currentTabIndex: 0

    anchorPosition: "top"
    animationType: 1
    margins: 10
    screenMargin: 10
    cornerRadius: 24
    panelWidth: 700
    panelHeight: 400

    KeyboardShortcut {
        name: "controlCenter"
        onPressed: root.toggleWindow()
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ── Header (unchanged) ────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8

            Column {
                spacing: 0

                Row {
                    spacing: 2

                    RavenText {
                        text: TimeService.hourString
                        fontSize: 24
                    }

                    RavenText {
                        text: ":"
                        fontSize: 24
                        color: ColorService.colorPalette.accentonPrimary
                    }

                    RavenText {
                        text: TimeService.minuteString
                        fontSize: 24
                    }
                }

                RavenText {
                    text: TimeService.dayofWeek + ", " + TimeService.format("MMM dd")
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 8

                RavenText {
                    text: "mikaleio"
                    font.pixelSize: 12
                }

                ClippingRectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16

                    Image {
                        anchors.fill: parent
                        source: "///home/mikaelio/.face.icon"
                    }
                }

                ButtonIcon {
                    iconName: Icons.settings.gear
                    buttonPadding: 6
                }

                ButtonIcon {
                    iconName: Icons.power.shutdown
                    buttonPadding: 6
                    onClicked: PowerService.shutdown()
                }

                ButtonIcon {
                    iconName: Icons.utilities.dismiss
                    buttonPadding: 6
                    onClicked: root.closeWindow()
                }
            }
        }

        // ── Divider ───────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: ColorService.colorPalette.textPrimary
            opacity: 0.12
        }

        // ── Body: left tab rail | right content ───────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ── Left tab rail ─────────────────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.margins: 8
                spacing: 4

                Repeater {
                    // No overlay
                    // Weather overlay added here
                    // ── The Dynamic Overlay ──

                    model: [
                        {
                            "icon": Icons.utilities.home,
                            "overlay": "",
                            "tab": 0
                        },
                        {
                            "icon": Icons.network.wifi.high,
                            "overlay": Icons.bluetooth.enabled,
                            "tab": 1
                        },
                        {
                            "icon": Icons.system.cpu,
                            "overlay": "",
                            "tab": 2
                        },
                        {
                            "icon": Icons.utilities.calendar,
                            "overlay": Icons.utilities.weather,
                            "tab": 3
                        },
                        {
                            "icon": Icons.notifications.bell,
                            "overlay": "",
                            "tab": 4
                        }
                    ]

                    delegate: RavenOverlayButton {
                        id: tabButton

                        required property var modelData

                        iconName: modelData.icon
                        bgIconName: modelData?.overlay
                        buttonPadding: 10
                        // Check if this is the active tab to change opacity/color
                        radius: 4
                        enabled: root.currentTabIndex === modelData.tab
                        onClicked: root.currentTabIndex = modelData.tab
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }

            // ── Vertical divider ──────────────────────────────────────
            Rectangle {
                Layout.fillHeight: true
                implicitWidth: 1
                color: ColorService.colorPalette.textPrimary
                opacity: 0.1
            }

            // ── Content area ──────────────────────────────────────────
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.topMargin: 10
                Layout.rightMargin: 0
                currentIndex: root.currentTabIndex

                // TAB 0: Dashboard — music + quick toggles
                RowLayout {
                    spacing: 4

                    MusicPlayerCard {
                        Layout.preferredWidth: 240
                        Layout.fillHeight: true
                    }
                    // Quick toggles

                    ColumnLayout {
                        // Add your toggle buttons here

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        QuickTogglesCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        PowerProfileCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        SlidersCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 180
                        }
                    }
                }

                // TAB 1: Network + Bluetooth
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    NetworkSelectorCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    BluetoothSelectorCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                // TAB 2: System info
                SystemCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                //Tab 3: Weather and Calendar tab
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    WeatherCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // TAB 3: Notifications
                NotificationsCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
