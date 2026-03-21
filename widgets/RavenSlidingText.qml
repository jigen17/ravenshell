import QtQuick

Item {
    id: root

    // --- Aliases & API ---
    property alias text: text1.text
    property alias font: text1.font
    property alias textColor: text1.color
    
    // Internal Settings
    property int textSpacing: 10
    property int velocity: 30 
    
    readonly property bool needsAnimation: text1.width > root.width && root.width > 0
    property bool running: false
    implicitHeight: text1.height
    clip: true

    // Duration for a full trip (from Right to Left)
    function calculateFullDuration() {
        let dist = root.width + text1.width + textSpacing;
        return (dist / velocity) * 1000;
    }

    // Duration for the very first move (from Center to Left)
    function calculateInitialDuration() {
        let startX = (root.width / 2) - (text1.width / 2);
        let endX = -text1.width;
        let dist = Math.abs(startX - endX);
        return (dist / velocity) * 1000;
    }

    Text {
        id: text1
        text: "No Track Playing"
        font.pixelSize: 16
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        
        // Starting position: Center
        x: (root.width / 2) - (text1.width / 2)

        SequentialAnimation on x {
            id: marqueeAnimation
            running: root.needsAnimation && root.running
            
            // 1. First time only: Move from Center to completely off-screen Left
            NumberAnimation {
                from: (root.width / 2) - (text1.width / 2)
                to: -text1.width
                duration: root.calculateInitialDuration()
                easing.type: Easing.Linear
            }

            // 2. Infinite Loop: Start from Right edge and go to Left edge
            NumberAnimation {
                from: root.width + root.textSpacing // Start from the far right
                to: -text1.width // End at the far left
                duration: root.calculateFullDuration()
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }
        }
        
        onTextChanged: {
            marqueeAnimation.restart();
        }
    }

    // The "Follower" text for seamless looping
    Text {
        id: text2
        anchors.verticalCenter: parent.verticalCenter
        text: text1.text
        font: text1.font
        color: text1.color
        
        // This guy stays glued to the tail of text1
        x: text1.x + text1.width + root.textSpacing
        visible: root.needsAnimation
    }
}
