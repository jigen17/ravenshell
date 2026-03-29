import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.assets
import qs.config
import qs.modules.Notifications
import qs.services
import qs.widgets

Item {
    id: root

    // ── Background ───────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 12

        border {
            width: 2
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.1)
        }

    }

    ColumnLayout {
        spacing: 8

        anchors {
            fill: parent
            margins: 8
        }

        // ── Header ───────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            RavenText {
                text: `Notifications (${NotifService.history.length})`
                font.pixelSize: 13
                color: ColorService.colorPalette.textPrimary
            }

            Item {
                Layout.fillWidth: true
            }

            ButtonIcon {
                iconName: Icons.utilities.broom
                iconSize: 16
                buttonPadding: 8
                radius: 2
                enabled: NotifService.history.length > 0
                onClicked: NotifService.clearAllNotifs()
            }

        }

        // ── Divider ──────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.1)
        }

        // ── Content: empty state or list ─────────────────────────────
        Item {
            // Empty state

            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                spacing: 8
                visible: !listView.visible

                anchors {
                    centerIn: parent
                }

                RavenIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.notifications.bellSlash
                    iconSize: 48
                    opacity: 0.7
                }

                RavenText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No notifications"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: ColorService.colorPalette.textPrimary
                    opacity: 0.5
                }

                RavenText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "You're all caught up"
                    font.pixelSize: 11
                    color: ColorService.colorPalette.textPrimary
                    opacity: 0.3
                }

            }

            // List
            ListView {
                id: listView

                anchors.fill: parent
                visible: NotifService.history.length > 0
                model: NotifService.history
                clip: true
                spacing: 4
                flickableDirection: Flickable.VerticalFlick

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: NotifItem {
                    required property var modelData

                    notifItem: modelData
                    width: listView.width
                }

            }

        }

    }

}
