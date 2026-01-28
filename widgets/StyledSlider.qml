import QtQuick
import QtQuick.Controls
import Quickshell
import qs.services
import qs.config
import qs.assets
import qs.widgets

Slider {
  id: root
  
  // Customization properties
  property int radius: 0
  property color backgroundColor: ColorService.colorPalette.backgroundSecondary_100
  property color fillColor: ColorService.colorPalette.accentPrimary
  property bool showTooltip: true
  property string tooltipPrefix: ""
  property int tooltipDecimals: 0
  
  // Implicit size for better layout behavior  
  from: 0
  to: 1
  
  background: Rectangle {
    color: root.backgroundColor
    anchors.fill: parent
    radius: root.radius
    
    Rectangle {
      width: root.visualPosition * parent.width
      height: parent.height
      radius: parent.radius
      color: root.fillColor
    }
  }
  
  handle: null
  
  // Hover handler for tooltip
  HoverHandler {
    id: hoverHandler
    enabled: root.showTooltip
  }
  
  // Wheel handler for scroll control
  WheelHandler {
    id: wheelHandler
    enabled: root.wheelEnabled
    target: null
    onWheel: (event) => {
      const delta = event.angleDelta.y / 120
      const step = (root.to - root.from) * 0.02 // 5% per wheel tick
      root.value = Math.max(root.from, Math.min(root.to, root.value + (delta * step)))
      root.moved()
    }
  }
  
  // Tooltip that follows hover position
  RavenTooltip {
    id: tooltip
    parent: root
    x: {
      if (root.pressed) {
        // When pressed, follow the actual slider position
        return root.visualPosition * (root.width - width / 2) - width / 2
      } else {
        // When hovering, follow mouse position
        return Math.max(0, Math.min(root.width - width, hoverHandler.point.position.x - width / 2))
      }
    }
    y: -height - 8
    tooltipText: root.tooltipPrefix
    show: hoverHandler.hovered || root.pressed
    delay: 300
  }
}
