import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets

Rectangle {
    id: root
    implicitWidth: 270
    implicitHeight: 35
    color: ColorService.colorPalette.accentSecondary
    radius: 20
    property int widgetPadding: 8
    property int workspaceButtonSize: 28
    property int animDuration: 300
    
    // Subtle glow effect for active workspace
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
    
    // Active workspace pill background with glow
    Rectangle {
        id: activeHighlight
        z: 0
        
        property int activeIndex: getActiveWorkspaceIndex()
        property real targetX: activeIndex * workspaceButtonSize + widgetPadding
        
        x: targetX
        implicitWidth: workspaceButtonSize
        implicitHeight: workspaceButtonSize
        anchors.verticalCenter: parent.verticalCenter
        
        radius: implicitWidth / 2        
        color: ColorService.colorPalette.accentPrimary_300
        
        
        Behavior on x {
            NumberAnimation {
                duration: animDuration
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on implicitWidth {
            NumberAnimation {
                duration: animDuration
                easing.type: Easing.OutCubic
            }
        }
    }
    
    // Workspace buttons
    ListView {
        id: workspaceList
        anchors.fill: parent
        anchors.margins: widgetPadding
        
        orientation: ListView.Horizontal
        spacing: 0
        interactive: false
        
        model: HyprlandService.visibleWorkspaces
        
        delegate: Item {
            id: workspaceButton
            required property var modelData
            required property int index
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: workspaceButtonSize
            implicitHeight: workspaceButtonSize
            z: 2
            
            property bool isActive: modelData.state === "focused"
            property bool isOccupied: modelData.isOccupied
            property bool isUrgent: modelData.isUrgent || false
            
            // Hover and press animations
            property real hoverScale: 1.0
            scale: hoverScale
            transformOrigin: Item.Center
            
            Behavior on scale {
                NumberAnimation { 
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            
            // Content container
            Item {
                anchors.centerIn: parent
                implicitWidth: workspaceButtonSize
                implicitHeight: workspaceButtonSize
                
                // Urgent indicator pulse (enhanced)
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
                    
                    SequentialAnimation on implicitWidth {
                        running: urgentPulse.visible
                        loops: Animation.Infinite
                        NumberAnimation { to: workspaceButtonSize * 1.1; duration: 700; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: workspaceButtonSize; duration: 700; easing.type: Easing.InOutQuad }
                    }
                    
                    SequentialAnimation on implicitHeight {
                        running: urgentPulse.visible
                        loops: Animation.Infinite
                        NumberAnimation { to: workspaceButtonSize * 1.1; duration: 700; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: workspaceButtonSize; duration: 700; easing.type: Easing.InOutQuad }
                    }
                }
                
                // Empty workspace dot (enhanced visibility)
                Rectangle {
                    id: workspaceDot
                    anchors.centerIn: parent
                    visible: !workspaceButton.isOccupied
                    
                    implicitWidth: workspaceButton.isActive ? 10 : 6
                    implicitHeight: implicitWidth
                    radius: implicitWidth / 2
                    
                    color: ColorService.colorPalette.accentPrimary
                    
                    Behavior on implicitWidth {
                        NumberAnimation { 
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                // App icon with better sizing
                IconImage {
                    id: appIcon
                    anchors.centerIn: parent
                    visible: workspaceButton.isOccupied && modelData.app
                    
                    property var entry: visible ? DesktopEntries.heuristicLookup(modelData.app) : null
                    
                    source: Quickshell.iconPath(entry?.icon)
                    
                    // Larger icon for active workspace
                    implicitSize: 24
                    smooth: true
                    antialiasing: true
                    asynchronous: true
                    mipmap: true
                    opacity: 0
                    Component.onCompleted: {
                        fadeIn.start()
                    }
                    
                    NumberAnimation on opacity {
                        id: fadeIn
                        to: workspaceButton.isActive ? 1.0 : 0.85
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                }
                
                // Workspace number badge (bottom-right corner)
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
                    scale: 0.8
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { 
                            duration: 200
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.5
                        }
                    }
                    
                    RavenText {
                        anchors.centerIn: parent
                        text: modelData.workspaceId
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: ColorService.colorPalette.accentonPrimary
                    }
                }
                
                // Workspace number overlay for empty workspaces
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
                    scale: 0.9
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { 
                            duration: 200
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }
            
            // Mouse interaction
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                onClicked: {
                    HyprlandService.activate(modelData.id);
                }
                
                onEntered: {
                    workspaceButton.hoverScale = 1.15;
                    
                    if (!workspaceButton.isOccupied) {
                        workspaceNumber.opacity = 0.7;
                        workspaceNumber.scale = 1.0;
                    } else {
                        numberBadge.opacity = 1.0;
                        numberBadge.scale = 1.0;
                    }
                }
                
                onExited: {
                    workspaceButton.hoverScale = 1.0;
                    workspaceNumber.opacity = 0;
                    workspaceNumber.scale = 0.9;
                    numberBadge.opacity = 0;
                    numberBadge.scale = 0.8;
                }
                
                onPressed: {
                    workspaceButton.hoverScale = 0.9;
                }
                
                onReleased: {
                    workspaceButton.hoverScale = containsMouse ? 1.15 : 1.0;
                }
            }
        }
    }
    
    function getActiveWorkspaceIndex() {
        for (let i = 0; i < HyprlandService.visibleWorkspaces.length; i++) {
            if (HyprlandService.visibleWorkspaces[i].id === HyprlandService.activeWsId) {
                return i;
            }
        }
        return 0;
    }
}
