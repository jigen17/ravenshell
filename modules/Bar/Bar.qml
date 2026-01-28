import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.services
import qs.config
import qs.widgets
import qs.assets
import "components"
import "components/Tray"

Variants {
    model: Quickshell.screens

    LazyLoader {
        id: loader
        required property var modelData
        active: true

        PanelWindow {
            screen: loader.modelData
            anchors {
                top: true
                bottom: true
                left: true
            }
            margins {
                top: 10
                bottom: 10
                left: 5
            }

            exclusionMode: ExclusionMode.Auto
            exclusiveZone: 1
            color: "transparent"

            readonly property int panelWidth: 35
            implicitWidth: panelWidth + Ui.tokens.spacing.sm * 2

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(ColorService.colorPalette.backgroundSecondary.r, ColorService.colorPalette.backgroundSecondary.g, ColorService.colorPalette.backgroundSecondary.b, 1)
                radius: 18
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    spacing: 8

                    ButtonIcon {
                        iconName: Icons.notifications.bell
                        Layout.alignment: Qt.AlignHCenter
                        buttonPadding: Ui.tokens.spacing.sm
                    }
                    ResourceItem {
                        Layout.alignment: Qt.AlignHCenter
                    }
                                        TrayItem {
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Workspaces {
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                    BatteryIndicator {
                        Layout.alignment: Qt.AlignHCenter
                    }
                    TimeItem {
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ButtonIcon {
                        iconName: Icons.power.shutdown
                        Layout.alignment: Qt.AlignHCenter
                        buttonPadding: Ui.tokens.spacing.sm
                    }
                }
            }
        }
    }
}
