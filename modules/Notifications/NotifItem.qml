pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.services
import qs.assets
import qs.widgets
import qs.config

Item {
    id: root
    required property var notifItem
    signal dismissed

    // Size driven by content, never below 140
    implicitWidth: 360

    // ── Frosted glass card ──────────────────────────────────────────────
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(0.11, 0.11, 0.12, 0.82)
        border.color: Qt.rgba(1, 1, 1, 0.09)
        border.width: 1
        clip: true
    }

    MultiEffect {
        source: card
        anchors.fill: card
        blurEnabled: true
        blur: 1.0
        blurMax: 32
        shadowEnabled: true
        shadowColor: "#60000000"
        shadowBlur: 0.8
        shadowVerticalOffset: 1
        shadowHorizontalOffset: 0
    }

    // ── Hover / timer ───────────────────────────────────────────────────
    HoverHandler {
        id: hover
        onHoveredChanged: hover.hovered ? root.notifItem.pauseTimer() : root.notifItem.resumeTimer()
    }

    // ── Main row ────────────────────────────────────────────────────────
    RowLayout {
        id: mainRow
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Icon — top-aligned
        Rectangle {
            id: iconBackground
            width: 44
            height: 44
            radius: 11
            color: "#1e1e1f"
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
            Layout.alignment: Qt.AlignTop

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                implicitSize: 30
                visible: root.notifItem.appIcon !== ""
                source: Quickshell.iconPath(root.notifItem.appIcon)
                smooth: true
            }

            RavenText {
                anchors.centerIn: parent
                visible: !appIcon.visible
                text: root.notifItem.appName ? root.notifItem.appName.charAt(0).toUpperCase() : "?"
                font.pixelSize: 20
                font.bold: true
                color: "white"
            }
        }

        // Right column — grows with content
        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: 0

            Component.onCompleted: {
                Qt.callLater(() => root.implicitHeight = Math.max(140, contentColumn.implicitHeight + 28))
            }

            // App name + dismiss
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                RavenText {
                    text: (root.notifItem.appName ?? "").toUpperCase()
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.letterSpacing: 0.4
                    color: "white"
                    opacity: 0.45
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                ButtonIcon {
                    iconName: Icons.utilities.dismiss
                    iconSize: 9
                    buttonPadding: 6
                    opacity: hover.hovered ? 0.7 : 0.0
                    enabled: true
                    onClicked: root.dismissed()

                    Behavior on opacity {
                        NumberAnimation { duration: 120; easing.type: Easing.InOutQuad }
                    }
                }
            }

            // Summary
            RavenText {
                text: root.notifItem.summary
                font.pixelSize: 13
                font.weight: 500
                color: "white"
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.topMargin: 1
            }

            // Body — up to 5 lines
            RavenText {
                visible: root.notifItem.body !== ""
                text: root.notifItem.body
                Layout.fillWidth: true
                Layout.topMargin: 4
                font.pixelSize: 12
                color: "white"
                opacity: 0.72
                maximumLineCount: 5
                wrapMode: Text.WordWrap
                lineHeight: 1.25
                elide: Text.ElideRight
            }

            // Spacer — pushes reply + actions to the bottom
            Item { Layout.fillHeight: true }

            // Inline reply
            TextField {
                visible: root.notifItem.hasInlineReply
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.preferredHeight: 28
                focus: true
                placeholderText: root.notifItem.inlineReplyPlaceholder
                color: "white"
                placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                font.pixelSize: 12
                leftPadding: 8

                background: Rectangle {
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1
                }

                Keys.onReturnPressed: root.notifItem.sendInlineReply(text)
                Component.onCompleted: { if (root.notifItem.hasInlineReply) forceActiveFocus() }
                onVisibleChanged: { if (visible) forceActiveFocus() }
            }

            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 6
                visible: root.notifItem.actions !== null && root.notifItem.actions.length > 0

                Repeater {
                    model: root.notifItem.actions
                    delegate: RavenTextButton {
                        id: actionBtn
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        text: actionBtn.modelData.text
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        radius: 6
                        backgroundColor: Qt.rgba(1, 1, 1, 0.1)
                        onClicked: {
                            modelData.invoke()
                            root.dismissed()
                        }
                    }
                }
            }
        }
    }
}
