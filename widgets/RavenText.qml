import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

Text {
  id: root
  property color textColor: ColorService.colorPalette.textSecondary
  property  double fontSize: Ui.tokens.fontSize.sm
  color: root.textColor
  font.pixelSize: root.fontSize
  font.family: Settings.config.fonts.primary
  font.weight: 500
  renderType: Text.HighRenderTypeQuality
  antialiasing: true
  smooth: true
}
