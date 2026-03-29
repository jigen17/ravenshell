import QtQuick
import QtQuick.Shapes

Item {
    id: root
    implicitWidth:  300
    implicitHeight: 100

    property color backgroundColor: "#11111b"
    property color fillColor:       "#87b2fabf"
    property color strokeColor:     "#86b2d0"
    property int   strokeWidth:     2
    property int   maxPoints:       11

    // ── public API — value must be 0.0 to 1.0 ───────────────────
    property real value: 0
    onValueChanged: _push(value)

    // ── internals ────────────────────────────────────────────────
    property var _points: new Array(maxPoints).fill(0)

    function _push(v) {
        const next = [..._points, Math.max(0, Math.min(1, v))]
        if (next.length > maxPoints) next.shift()
        _points = next
    }


    Shape {
        id: shape
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        readonly property real stepX: root.width / (root.maxPoints - 1)

        ShapePath {
            id: graphPath
            strokeColor: root.strokeColor
            fillColor:   root.fillColor
            strokeWidth: root.strokeWidth
            capStyle:    ShapePath.RoundCap
            joinStyle:   ShapePath.RoundJoin
            startX: 0
            startY: root.height
        }

        Connections {
            target: root
            function on_PointsChanged() { shape._build() }
        }

        function _build() {
            const pts = root._points
            const h   = root.height
            const sx  = stepX
            const elems = []

            graphPath.startY = h - pts[0] * h

            for (let i = 1; i < pts.length; i++) {
                const seg = Qt.createQmlObject('import QtQuick; PathLine {}', graphPath)
                seg.x = i * sx
                seg.y = h - pts[i] * h   // 0.0 → bottom, 1.0 → top
                elems.push(seg)
            }

            const br = Qt.createQmlObject('import QtQuick; PathLine {}', graphPath)
            br.x = (pts.length - 1) * sx
            br.y = h

            const bl = Qt.createQmlObject('import QtQuick; PathLine {}', graphPath)
            bl.x = 0
            bl.y = h

            elems.push(br, bl)
            graphPath.pathElements = elems
        }
    }
}
