import QtQuick
import Quickshell
import qs.assets
import qs.config
import qs.services

Item {
    id: root
    implicitWidth: 28
    implicitHeight: implicitWidth
    
    property real progress: 0.5
    property color accentColor: ColorService.colorPalette.accentonPrimary
    property color backgroundColor: ColorService.colorPalette.backgroundSecondary_300
    property real gapAngle: 60
    property string iconName: ""
    
    // LAYER 1: Static background arc (drawn once, cached)
    Canvas {
        id: backgroundCanvas
        anchors.fill: parent
        antialiasing: true
        layer.enabled: true  // Cache this - never changes!
        z: 0
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2, cy = height / 2, r = 12, lw = 5;
            var start = (Math.PI / 2) + (root.gapAngle * Math.PI / 180);
            var total = (360 - 2 * root.gapAngle) * Math.PI / 180;
            
            // Only draw the background arc
            ctx.strokeStyle = root.backgroundColor;
            ctx.lineWidth = lw;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + total, false);
            ctx.stroke();
        }
        
        Component.onCompleted: requestPaint()
    }
    
    // LAYER 2: Dynamic progress arc (redraws only this!)
    Canvas {
        id: progressCanvas
        anchors.fill: parent
        antialiasing: true
        z: 1
        // NO layer.enabled - updates frequently!
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2, cy = height / 2, r = 12, lw = 4;
            var start = (Math.PI / 2) + (root.gapAngle * Math.PI / 180);
            var total = (360 - 2 * root.gapAngle) * Math.PI / 180;
            var prog = root.progress * total;
            
            ctx.lineCap = "round";
            
            // Only draw the progress arc
            if (prog > 0.01) {
                var startX = cx + r * Math.cos(start);
                var startY = cy + r * Math.sin(start);
                var endX = cx + r * Math.cos(start + total);
                var endY = cy + r * Math.sin(start + total);
                
                var gradient = ctx.createLinearGradient(startX, startY, endX, endY);
                gradient.addColorStop(0, root.accentColor);
                gradient.addColorStop(0.45, root.accentColor);
                gradient.addColorStop(0.65, "#FF9500");
                gradient.addColorStop(0.85, "#FF9500");
                gradient.addColorStop(0.85, "#FF3B30");
                gradient.addColorStop(1, "#FF3B30");
                
                ctx.strokeStyle = gradient;
                ctx.lineWidth = lw;
                ctx.beginPath();
                ctx.arc(cx, cy, r, start, start + prog, false);
                ctx.stroke();
            }
        }
    }
    
    // LAYER 3: Static icon (never redraws)
    Text {
        anchors.centerIn: parent
        text: root.iconName
        font.family: Icons.font
        font.pixelSize: Ui.tokens.iconSize.xs
        color: ColorService.colorPalette.textSecondary
        z: 2
        // Text is already efficient, no layer needed
    }
    
    onProgressChanged: progressCanvas.requestPaint()  // Only repaint progress!
}

