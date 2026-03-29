import QtQuick
import Quickshell
import qs.assets
import qs.config
import qs.services

Item {
    id: root

    property real progress: 0.5
    property color accentColor: ColorService.colorPalette.accentonPrimary
    property color backgroundColor: ColorService.colorPalette.backgroundSecondary_300
    property real gapAngle: 60
    property Component centerItem

    implicitHeight: width
    onProgressChanged: progressCanvas.requestPaint()

    // LAYER 1: Static background arc (drawn once, cached)
    Canvas {
        id: backgroundCanvas

        anchors.fill: parent
        antialiasing: true
        layer.enabled: true
        z: 0
        onWidthChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2, cy = height / 2;
            var r = width * 0.38;
            var lw = width * 0.1;
            var start = (Math.PI / 2) + (root.gapAngle * Math.PI / 180);
            var total = (360 - 2 * root.gapAngle) * Math.PI / 180;
            ctx.strokeStyle = root.backgroundColor;
            ctx.lineWidth = lw;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + total, false);
            ctx.stroke();
        }
        Component.onCompleted: requestPaint()
    }

    // LAYER 2: Dynamic progress arc (redraws on progress change)
    Canvas {
        id: progressCanvas

        anchors.fill: parent
        antialiasing: true
        z: 1
        onWidthChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2, cy = height / 2;
            var r = width * 0.38;
            var lw = width * 0.07;
            var start = (Math.PI / 2) + (root.gapAngle * Math.PI / 180);
            var total = (360 - 2 * root.gapAngle) * Math.PI / 180;
            var prog = root.progress * total;
            ctx.lineCap = "round";
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

    Loader {
        anchors.centerIn: parent
        active: true
        sourceComponent: root.centerItem
    }

}
