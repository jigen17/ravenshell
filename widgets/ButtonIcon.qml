import QtQuick
import Quickshell
import qs.services
import qs.config
import qs.assets

Item {
    id: root
    
    // Public properties
    property alias iconName: icon.text
    property alias iconFamily: icon.font.family
    property color iconColor: ColorService.colorPalette.textPrimary
    property int iconSize: 24
    property int buttonPadding: 0
    property color backgroundColor: "transparent"
    property color hoverColor: Qt.lighter(backgroundColor, 1.2)
    property color enabledColor: ColorService.colorPalette.accentonPrimary
    property color pressedColor: Qt.darker(hoverColor, 1.1)
    property bool enabled: false
    property int radius: 16
   property bool roundButton: true 
    implicitWidth: icon.implicitWidth + buttonPadding * 2
    implicitHeight: implicitWidth
    
    // Signals
    signal clicked
    signal pressed
    signal released
    
    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.enabled && root.roundButton ? root.radius + 10 : root.radius
        
        // Original binding - it's fine as is
        color: {
            if (root.enabled)
                return root.enabledColor;
            if (mouseArea.pressed)
                return root.pressedColor;
            if (mouseArea.containsMouse)
                return root.hoverColor;
            return root.backgroundColor;
        }
        
        antialiasing: true
        scale: mouseArea.pressed ? 0.95 : 1.0
        
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
        
        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
        
        Behavior on radius {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
    
    // Icon
    Text {
        id: icon
        anchors.centerIn: parent
        color: root.iconColor
        font.family: Icons.font
        font.pixelSize: root.iconSize
        renderType: Text.HighRenderTypeQuality
        antialiasing: true
        scale: mouseArea.containsMouse && !mouseArea.pressed ? 1.15 : 1.0
        
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
        
        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
    
    // Mouse interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onPressed: root.pressed()
        onReleased: root.released()
    }
    

}
