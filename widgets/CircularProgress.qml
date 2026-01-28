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
    property color accentColor: ColorService.colorPalette.accentPrimary
    property color backgroundColor : ColorService.colorPalette.backgroundSecondary_300
    property real gapAngle: 60
    property string iconName: ""
    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2, cy = height / 2, r = 12, lw = 4;
            var start = (Math.PI / 2) + (gapAngle * Math.PI / 180);
            var total = (360 - 2 * gapAngle) * Math.PI / 180;
            var prog = progress * total;
            ctx.lineCap = "round";
            
            // Progress with static gradient across the whole arc
            if (prog > 0.01) {
                var startX = cx + r * Math.cos(start);
                var startY = cy + r * Math.sin(start);
                var endX = cx + r * Math.cos(start + total);
                var endY = cy + r * Math.sin(start + total);
                
                var gradient = ctx.createLinearGradient(startX, startY, endX, endY);
                gradient.addColorStop(0, accentColor);
                gradient.addColorStop(0.45, accentColor);
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
            
            // Remaining
            if (start + prog < start + total) {
              ctx.strokeStyle = root.backgroundColor;
                ctx.lineWidth = lw;
                ctx.beginPath();
                ctx.arc(cx, cy, r, start + prog, start + total, false);
                ctx.stroke();
            }
        }
    }
    Text {
        anchors.centerIn: parent
        text: root.iconName
        font.family: Icons.font
        font.pixelSize: Ui.tokens.iconSize.xs
        color: ColorService.colorPalette.textSecondary
    }
    onProgressChanged: canvas.requestPaint()
}
