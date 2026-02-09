import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.config
import qs.widgets
import qs.assets
import qs.services
import "components"

Variants {
    model: Quickshell.screens
    
    Loader {
        id: loader
        required property var modelData
        active: true
        sourceComponent: PanelWindow {
            screen: loader.modelData
            anchors {
                top: true
            }
            
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            implicitWidth: workspaces.width + 80
            implicitHeight: 45
            
            Item {
                id: root
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 8
                
                property real cornerRadius: 15
                property real notchWidth: 20
                property real shapeHeight: 55  // Control shape height separately
                

                
                Shape {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: parent.width
                    height: root.shapeHeight  // Use custom shape height
                    vendorExtensionsEnabled: false
                    
                    ShapePath {
                        strokeColor: "transparent"
                        fillColor: ColorService.colorPalette.backgroundPrimary
                        
                        // Start at top-left corner
                        startX: 0
                        startY: 0
                        
                        // Top edge - full width
                        PathLine {
                            relativeX: root.width
                            relativeY: 0
                        }
                        
                        // RIGHT SIDE: Top to Bottom (curves inward toward center)
                        // First curve - inward
                        PathQuad {
                            relativeX: -root.notchWidth
                            relativeY: root.cornerRadius
                            relativeControlX: -root.notchWidth * 0.5
                            relativeControlY: 0
                        }
                        
                        // Second curve - continues inward to bottom
                        PathQuad {
                            relativeX: -root.notchWidth
                            relativeY: root.shapeHeight - root.cornerRadius * 2
                            relativeControlX: -root.notchWidth * 0.5
                            relativeControlY: root.shapeHeight - root.cornerRadius * 2
                        }
                        
                        // Bottom: right to left (narrow part)
                        PathLine {
                            relativeX: -(root.width - root.notchWidth * 4)
                            relativeY: 0
                        }
                        
                        // LEFT SIDE: Bottom to Top (curves inward toward center)
                        // First curve - inward
                        PathQuad {
                            relativeX: -root.notchWidth
                            relativeY: -root.cornerRadius
                            relativeControlX: -root.notchWidth * 0.5
                            relativeControlY: 0
                        }
                        
                        // Second curve - continues inward to top
                        PathQuad {
                            relativeX: -root.notchWidth
                            relativeY: -(root.shapeHeight - root.cornerRadius * 2)
                            relativeControlX: -root.notchWidth * 0.5
                            relativeControlY: -(root.shapeHeight - root.cornerRadius * 2)
                        }
                    }
                }
                
                Workspaces {
                    id: workspaces
                    anchors.centerIn: parent
                }
            }
        }
    }
}
