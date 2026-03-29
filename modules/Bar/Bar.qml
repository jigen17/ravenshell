import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
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
                right: true
                left: true
            }
            margins {
                bottom: -5
                right: 10
                left: 10
                top: 5
            }
            exclusionMode: ExclusionMode.Auto
            WlrLayershell.layer: WlrLayer.Top
            color: "transparent"
            implicitHeight: 45

            Item {
                id: root
                anchors.fill: parent
                anchors.bottomMargin: 5

                property real arcWidth: 20
                property real arcHeight: 15
                property real panelHeight: 40
                property real workspaceExtraHeight: 15
                property real notchWidth: 20
                property int cornerRadius: 10

                // Fixed widths for static background
                property real estimatedLeftWidth: 100
                property real estimatedRightWidth: 320
                property real estimatedWorkspaceWidth: 250

                // Get monitor name from parent panel's screen
                property string monitorName: screen?.name ?? ""

                // Static background shape - separate layer, never redraws

Item {
    id: blurContainer
    anchors.fill: parent
    clip: true  // ← hard clip: no blur bleeds outside this item

    Rectangle {
        id: backgroundShape
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(
            ColorService.colorPalette.backgroundPrimary.r,
            ColorService.colorPalette.backgroundPrimary.g,
            ColorService.colorPalette.backgroundPrimary.b,
            0.3
        )
    }

    MultiEffect {
        source: backgroundShape
        anchors.fill: backgroundShape
        shadowEnabled: true
        blurEnabled: true
        blur: 1       // ← much more reasonable value
        blurMax: 16      // ← tighter radius
        autoPaddingEnabled: false  // ← disable auto-expansion
    }
}

                RowLayout {
                    id: leftRow
                    spacing: Ui.tokens.spacing.md
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 20
                    }
                    ResourceItem {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                Workspaces {
                    id: workspaces
                    anchors.centerIn: parent
                    monitorName: root.monitorName
                }

                RowLayout {
                    id: rightRow

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20
                    }
                    spacing: Ui.tokens.spacing.md
                    onWidthChanged: root.estimatedRightWidth = width + 30
                    TrayItem {}
                    TimeItem {}
                    RavenIcon {
                        iconName: Icons.notifications.bell
                    }
                    BatteryIndicator {}
                }

                Component.onCompleted: console.log("App", DesktopEntries.heuristicLookup("dolphin"))
            }
        }
    }
}
