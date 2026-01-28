pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.services
import qs.config
import qs.assets

Rectangle {
    id: root
    
    // Public properties
    property alias text: text.text
    property alias fontFamily: text.font.family
    property color textColor: ColorService.colorPalette.textPrimary
    property int fontSize: Ui.tokens.fontSize.sm
    property int buttonPadding: 0
    property color backgroundColor: "transparent"
    property color hoverColor:  Qt.lighter(backgroundColor,1.2)
    property color enabledColor: ColorService.colorPalette.accentPrimary
    property color pressedColor: Qt.darker(root.hoverColor, 1.1)
    property bool enabled: false

    implicitWidth: text.implicitWidth + root.buttonPadding * 2
    implicitHeight: implicitWidth
    
    // Signals
    signal clicked
    signal pressed
    signal released
    
    // Visual state
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
    smooth: true
    
    // Scale only the background, not the icon
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
    
    Behavior on opacity {
        NumberAnimation {
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
    Text {
        id: text
        anchors.centerIn: parent
        color: root.textColor
        font.family: Settings.config.fonts.primary
        font.pixelSize: root.fontSize
        renderType: Text.HighRenderTypeQuality
        antialiasing: true
        smooth: true
        
        // Scale the icon itself, not the parent
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
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onPressed: root.pressed()
        onReleased: root.released()
    }
    
    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.name: root.iconName
    Accessible.onPressAction: if (root.enabled) root.clicked()
}

