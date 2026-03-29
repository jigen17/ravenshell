import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets

Item {
    id: root
    implicitHeight: 28
    implicitWidth: 100
    property int widgetPadding: 8
    property int workspaceButtonSize: 24
    property int animDuration: 200
    
    // Auto-detect monitor from parent panel
    property string monitorName: {
        if (parent && parent.screen) {
            // If parent has screen property (from PanelWindow)
            return parent.screen.name;
        } else if (parent && parent.outputs) {
            // If parent is a monitor object
            return parent.name;
        }
        return ""; // Fallback: will use all workspaces
    }
    
    // LAYER 1: Static background
    Rectangle {
        id: background
        anchors.fill: parent
        color: ColorService.colorPalette.accentPrimary
        radius: 20
    }
    
    WheelHandler {
        target: root
        cursorShape: Qt.PointingHandCursor
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (event.angleDelta.y < 0)
                HyprlandService.dispatch("workspace e+1");
            else if (event.angleDelta.y > 0)
                HyprlandService.dispatch("workspace e-1");
        }
    }
    
    // Get workspaces for this monitor
    readonly property var monitorWorkspaces: root.monitorName 
        ? HyprlandService.getMonitorWorkspaces(root.monitorName)
        : HyprlandService.visibleWorkspaces
    
    // LAYER 2: Content container
    Item {
        id: contentContainer
        anchors.centerIn: parent
        implicitWidth: rowLayout.implicitWidth
        implicitHeight: parent.height
        
        // Active workspace pill
        Rectangle {
            id: activeHighlight
            z: 1
            
            property int activeIndex: getActiveWorkspaceIndex()
            
            x: 0
            implicitWidth: workspaceButtonSize
            implicitHeight: workspaceButtonSize
            anchors.verticalCenter: parent.verticalCenter
            
            radius: implicitWidth / 2        
            color: ColorService.colorPalette.accentPrimary_100
            
            transform: Translate {
                x: activeHighlight.activeIndex * root.workspaceButtonSize
                
                Behavior on x {
                    NumberAnimation {
                        duration: root.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            Behavior on implicitWidth {
                NumberAnimation {
                    duration: root.animDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        // Workspace buttons
        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 0
            z: 2

            Component.onCompleted: root.implicitWidth = implicitWidth + 10
            Repeater {
                model: root.monitorWorkspaces
                
                Item {
                    id: workspaceButton
                    required property var modelData
                    required property int index
                    Layout.preferredWidth: root.workspaceButtonSize
                    Layout.preferredHeight: root.workspaceButtonSize
                    
                    property bool isActive: modelData.state === "focused"
                    property bool isOccupied: modelData.isOccupied
                    property bool isUrgent: modelData.isUrgent || false
                    
                    // GPU-accelerated scale
                    transform: Scale {
                        id: scaleTransform
                        origin.x: root.workspaceButtonSize / 2
                        origin.y: root.workspaceButtonSize / 2
                        xScale: 1.0
                        yScale: 1.0
                        
                        Behavior on xScale {
                            NumberAnimation { 
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                        
                        Behavior on yScale {
                            NumberAnimation { 
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                    
                    Item {
                        anchors.centerIn: parent
                        implicitWidth: root.workspaceButtonSize
                        implicitHeight: root.workspaceButtonSize
                        
                        // Urgent pulse indicator
                        Rectangle {
                            id: urgentPulse
                            anchors.centerIn: parent
                            implicitWidth: parent.implicitWidth
                            implicitHeight: parent.implicitHeight
                            radius: implicitWidth / 2
                            color: "transparent"
                            border.width: 2.5
                            border.color: "#ff5555"
                            visible: workspaceButton.isUrgent
                            opacity: 0.8
                            
                            SequentialAnimation on opacity {
                                running: urgentPulse.visible
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 700; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 0.9; duration: 700; easing.type: Easing.InOutQuad }
                            }
                            
                            transform: Scale {
                                origin.x: urgentPulse.width / 2
                                origin.y: urgentPulse.height / 2
                                
                                SequentialAnimation on xScale {
                                    running: urgentPulse.visible
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.1; duration: 700; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutQuad }
                                }
                                
                                SequentialAnimation on yScale {
                                    running: urgentPulse.visible
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.1; duration: 700; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                        
                        // Dot for empty workspace
                        Rectangle {
                            id: workspaceDot
                            anchors.centerIn: parent
                            visible: !workspaceButton.isOccupied
                            
                            implicitWidth: workspaceButton.isActive ? 10 : 6
                            implicitHeight: implicitWidth
                            radius: implicitWidth / 2
                            
                            color: ColorService.colorPalette.accentonPrimary
                            
                            Behavior on implicitWidth {
                                NumberAnimation { 
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                        
                        // App icon
                        IconImage {
                            id: appIcon
                            anchors.centerIn: parent
                            visible: workspaceButton.isOccupied && modelData.app
                            
                            property var entry: visible ? DesktopEntries.heuristicLookup(modelData.app) : null
                            
                            source: Quickshell.iconPath(entry?.icon)
                            
                            implicitSize: root.workspaceButtonSize * 0.8
                            smooth: true
                            antialiasing: true
                            asynchronous: true
                            mipmap: true
                            
                            opacity: workspaceButton.isActive ? 1.0 : 0.85
                            
                            Behavior on opacity {
                                NumberAnimation { 
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                        
                        // Number badge on hover (occupied workspace)
                        Rectangle {
                            id: numberBadge
                            visible: workspaceButton.isOccupied && mouseArea.containsMouse
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: -2
                            anchors.bottomMargin: -2
                            
                            implicitWidth: 14
                            implicitHeight: 14
                            radius: 7
                            
                            color: ColorService.colorPalette.accentPrimary
                            border.width: 1.5
                            border.color: ColorService.colorPalette.backgroundSecondary
                            
                            opacity: 0
                            
                            transform: Scale {
                                origin.x: numberBadge.width / 2
                                origin.y: numberBadge.height / 2
                                xScale: 0.8
                                yScale: 0.8
                                
                                Behavior on xScale {
                                    NumberAnimation { 
                                        duration: 150
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.5
                                    }
                                }
                                
                                Behavior on yScale {
                                    NumberAnimation { 
                                        duration: 150
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.5
                                    }
                                }
                            }
                            
                            Behavior on opacity {
                                NumberAnimation { duration: 100 }
                            }
                            
                            RavenText {
                                anchors.centerIn: parent
                                text: modelData.workspaceId
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: ColorService.colorPalette.accentonPrimary
                            }
                        }
                        
                        // Workspace number on hover (empty workspace)
                        RavenText {
                            id: workspaceNumber
                            anchors.centerIn: parent
                            text: modelData.workspaceId
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: workspaceButton.isActive
                                ? ColorService.colorPalette.accentonPrimary
                                : ColorService.colorPalette.textSecondary
                            opacity: 0
                            
                            transform: Scale {
                                origin.x: workspaceNumber.width / 2
                                origin.y: workspaceNumber.height / 2
                                xScale: 0.9
                                yScale: 0.9
                                
                                Behavior on xScale {
                                    NumberAnimation { 
                                        duration: 150
                                        easing.type: Easing.OutBack
                                    }
                                }
                                
                                Behavior on yScale {
                                    NumberAnimation { 
                                        duration: 150
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }
                            
                            Behavior on opacity {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        
                        onClicked: {
                            HyprlandService.activate(modelData.workspaceId, root.monitorName);
                        }
                        
                        onDoubleClicked: {
                            // Double-click to move window to this workspace
                            HyprlandService.dispatch("movetoworkspace " + modelData.actualWsId);
                        }
                        
                        onEntered: {
                            scaleTransform.xScale = 1.15;
                            scaleTransform.yScale = 1.15;
                            
                            if (!workspaceButton.isOccupied) {
                                workspaceNumber.opacity = 0.7;
                                workspaceNumber.transform.xScale = 1.0;
                                workspaceNumber.transform.yScale = 1.0;
                            } else {
                                numberBadge.opacity = 1.0;
                                numberBadge.transform.xScale = 1.0;
                                numberBadge.transform.yScale = 1.0;
                            }
                        }
                        
                        onExited: {
                            scaleTransform.xScale = 1.0;
                            scaleTransform.yScale = 1.0;
                            workspaceNumber.opacity = 0;
                            workspaceNumber.transform.xScale = 0.9;
                            workspaceNumber.transform.yScale = 0.9;
                            numberBadge.opacity = 0;
                            numberBadge.transform.xScale = 0.8;
                            numberBadge.transform.yScale = 0.8;
                        }
                        
                        onPressed: {
                            scaleTransform.xScale = 0.9;
                            scaleTransform.yScale = 0.9;
                        }
                        
                        onReleased: {
                            scaleTransform.xScale = containsMouse ? 1.15 : 1.0;
                            scaleTransform.yScale = containsMouse ? 1.15 : 1.0;
                        }
                    }
                }
            }
        }
    }
    
    function getActiveWorkspaceIndex() {
        for (let i = 0; i < root.monitorWorkspaces.length; i++) {
            if (root.monitorWorkspaces[i].id === HyprlandService.activeWsId) {
                return i;
            }
        }
        return 0;
    }
}
