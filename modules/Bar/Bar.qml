import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
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
                bottom: 0
            }
            exclusionMode: ExclusionMode.Auto
            color: "transparent"
            implicitHeight: 45

            Item {
                id: root
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 8

                property real arcWidth: 20
                property real arcHeight: 15
                property real panelHeight: 40
                property real workspaceExtraHeight: 15
                property real notchWidth: 40
                property int cornerRadius: 10
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#40000000"
                    shadowBlur: 0.6
                    shadowVerticalOffset: 2
                    shadowHorizontalOffset: 0
                }

                Shape {
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        strokeWidth: 0
                        strokeColor: "transparent"
                        fillColor: ColorService.colorPalette.backgroundPrimary

                        startX: 0
                        startY: 0

                        // Top edge: left to right
                        PathLine {
                            relativeX: root.width
                            relativeY: 0
                        }

                        // Right edge: top to bottom
                        PathLine {
                            relativeX: 0
                            relativeY: root.height
                        }

                        // Bottom edge: move left to start of right section curve
                        PathLine {
                            relativeX: -(rightRow.width)
                            relativeY: 0
                        }

                        // Right section: smooth S-curve going UP
                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: -root.height / 2
                            relativeControlX: -root.notchWidth / 2
                            relativeControlY: -2
                        }

                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: -(root.height / 2 - 10)
                            relativeControlX: -4
                            relativeControlY: -(root.height / 2 - 10)
                        }

                        PathLine {
                            relativeX: -(root.width / 2 - workspaces.width / 2 - rightRow.width - root.notchWidth * 2)
                            relativeY: 0
                        }

                        
                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: root.height / 2
                            relativeControlX: -root.notchWidth / 2
                            relativeControlY: 2
                        }
                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: root.height / 2 - 10
                            relativeControlX: -4
                            relativeControlY: root.height / 2 - 10
                        }

                        // Bottom of workspace area
                        PathLine {
                            relativeX: -(workspaces.width)
                            relativeY: 0
                        }

                        // Workspace left side: MIRROR of workspace right (going UP instead of DOWN)
                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: -(root.height / 2)
                            relativeControlX: -root.notchWidth / 2
                            relativeControlY: -2
                        }

                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: -(root.height / 2 - 10)
                            relativeControlX: -4
                            relativeControlY: -(root.height / 2 - 10)
                        }

                        // Top edge: continue left to left section
                        PathLine {
                            relativeX: -(root.width / 2 - leftRow.width - workspaces.width / 2 - root.notchWidth * 2 - 10)
                            relativeY: 0
                        }

                        // Left section: MIRROR of right section (going DOWN instead of UP)
                        
                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: root.height / 2
                            relativeControlX: -root.notchWidth / 2
                            relativeControlY: 2
                        }

                        PathQuad {
                            relativeX: -root.notchWidth / 2
                            relativeY: root.height / 2 - 10
                            relativeControlX: -4
                            relativeControlY: root.height / 2 - 10
                        }
                        // Bottom edge: finish left side
                        PathLine {
                            relativeX: -(leftRow.width + 10)
                            relativeY: 0
                        }

                        // Left edge: close the path
                        PathLine {
                            relativeX: 0
                            relativeY: -root.height
                        }
                    }
                }

                RowLayout {
                    id: leftRow
                    spacing: Ui.tokens.spacing.md
                    anchors {
                        left: parent.left
                        top: parent.top
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    ResourceItem {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                Workspaces {
                    id: workspaces
                    anchors.centerIn: parent
                }

                RowLayout {
                    id: rightRow
                    anchors {
                        right: parent.right
                        top: parent.top
                        verticalCenter: parent.verticalCenter
                        rightMargin: 10
                    }
                    spacing: Ui.tokens.spacing.md
                    TrayItem {}
                    TimeItem {}
                    RavenIcon {
                        iconName: Icons.notifications.bell
                    }
                    BatteryIndicator {}
                }
            }
        }
    }
}
