import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets
import qs.assets

StyledPanel {
  id: root
  
  KeyboardShortcut {
    name: "weatherCenter"
    onPressed: root.toggleWindow()
  }
  
  anchorPosition: "top"
  margins: 15
  cornerRadius: 33
  panelWidth: 450
  panelHeight: 330
  
  contentItem: ColumnLayout {
    anchors.fill: parent
    spacing: Ui.tokens.spacing.sm
    
    // Top section: Current weather and daily forecast
    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Ui.tokens.spacing.sm
      
      // Current weather card
      CurrentWeather{
        Layout.fillWidth: true
        Layout.fillHeight: true
      } 
      // Daily forecast
      WeatherDays {
        Layout.preferredWidth: 200
        Layout.fillHeight: true
      }
    }
    
    // Bottom section: Hourly forecast
    WeatherHourly {
      Layout.fillWidth: true
      Layout.preferredHeight: 120
    }
  }
}
