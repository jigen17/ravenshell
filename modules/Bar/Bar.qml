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
                bottom: -2
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
                    id: backgroundLayer
                    anchors.fill: parent
                    MultiEffect {
                        source: backgroundShape
                        anchors.fill: parent
                        shadowEnabled: true
                        shadowColor: Qt.rgba(ColorService.colorPalette.backgroundPrimary.r, ColorService.colorPalette.backgroundPrimary.g, ColorService.colorPalette.backgroundPrimary.b, 0.8)
                        shadowBlur: 0.2
                        shadowVerticalOffset: 2
                        shadowHorizontalOffset: 0
                        blurEnabled: true
                        blur: 1.0
                        blurMax: 32
                    }

                    Shape {
                        id: backgroundShape
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeWidth: 0
                            strokeColor: "transparent"
                            fillColor: Qt.rgba(ColorService.colorPalette.backgroundPrimary.r, ColorService.colorPalette.backgroundPrimary.g, ColorService.colorPalette.backgroundPrimary.b, 0.7)

                            startX: 0
                            startY: 0

                            PathLine {
                                relativeX: root.width
                                relativeY: 0
                            }

                            PathLine {
                                relativeX: 0
                                relativeY: root.height
                            }

                            PathLine {
                                relativeX: -(root.estimatedRightWidth - 10)
                                relativeY: 0
                            }

                            PathQuad {
                                relativeX: -root.notchWidth - 10
                                relativeY: -root.height / 2
                                relativeControlX: -root.notchWidth / 2
                                relativeControlY: 0
                            }

                            PathQuad {
                                relativeX: -root.notchWidth - 20
                                relativeY: -(root.height / 2 - 10)
                                relativeControlX: -root.notchWidth / 2
                                relativeControlY: -(root.height / 4)
                            }

                            PathLine {
                                relativeX: -(root.width / 2 - root.estimatedWorkspaceWidth / 2 - root.estimatedRightWidth - root.notchWidth * 3 - 40)
                                relativeY: 0
                            }

                            PathQuad {
                                relativeX: -root.notchWidth - 10
                                relativeY: root.height / 2
                                relativeControlX: -root.notchWidth / 2
                                relativeControlY: 0
                            }
                            PathQuad {
                                relativeX: -root.notchWidth
                                relativeY: root.height / 2 - 10
                                relativeControlX: -root.notchWidth / 2
                                relativeControlY: root.height / 4
                            }

                            PathLine {
                                relativeX: -(root.estimatedWorkspaceWidth - 20)
                                relativeY: 0
                            }

                            PathQuad {
                                relativeX: -root.notchWidth - 10
                                relativeY: -root.height / 2
                                relativeControlX: -root.notchWidth / 2
                                relativeControlY: 0
                            }

                            PathQuad {
                                relativeX: -root.notchWidth - 20
                                relativeY: -(root.height / 2 - 10)
                                relativeControlX: -root.notchWidth / 2
                                relativeControlY: -(root.height / 4)
                            }

                            PathLine {
                                relativeX: -(root.width / 2 - root.estimatedLeftWidth - root.estimatedWorkspaceWidth / 2 - root.notchWidth * 2 - 80)
                                relativeY: 0
                            }

                            PathQuad {
                                relativeX: -root.notchWidth - 10
                                relativeY: root.height / 2
                                relativeControlX: -root.notchWidth / 1.5
                                relativeControlY: 2
                            }
                            PathQuad {
                                relativeX: -root.notchWidth
                                relativeY: root.height / 2 - 10
                                relativeControlX: -root.notchWidth / 2
                                relativeControlY: root.height / 4
                            }
                            PathLine {
                                relativeX: -(root.estimatedLeftWidth + 20)
                                relativeY: 0
                            }

                            PathLine {
                                relativeX: 0
                                relativeY: -root.height
                            }
                        }
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
