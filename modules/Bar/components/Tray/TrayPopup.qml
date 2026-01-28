pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets

StyledPopup {
  id: root
  property alias menu: menuOpener.menu
  
  QsMenuOpener { 
    id: menuOpener
  }
  
  contentItem: ColumnLayout {
    anchors.fill: parent
    spacing: 1
    Keys.onEscapePressed: root.closeWindow()
    Repeater { 
      model: menuOpener.children
      
      delegate: Rectangle {
        required property QsMenuEntry modelData
        
        Layout.preferredWidth: 200
        Layout.preferredHeight: modelData.isSeparator ? 1 : rowContent.implicitHeight * 1.5
        
        color: {
          if (modelData.isSeparator) {
            return ColorService.colorPalette.textSecondary
          }
          return mouseArea.containsMouse ? 
            ColorService.colorPalette.accentPrimary :
            "transparent"
        }
        
        opacity: modelData.enabled ? 1.0 : 0.5
        radius: height / 3
        
        RowLayout {
          id: rowContent
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: 10
          spacing: 8
          visible: !modelData.isSeparator
          
          // Checkbox/Radio indicator
          Rectangle {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter
            
            visible: modelData.buttonType !== QsMenuButtonType.None
            color: "transparent"
            border.color: ColorService.colorPalette.textPrimary
            border.width: 1
            radius: modelData.buttonType === QsMenuButtonType.RadioButton ? 8 : 2
            
            Rectangle {
              anchors.centerIn: parent
              width: 8
              height: 8
              radius: modelData.buttonType === QsMenuButtonType.RadioButton ? 4 : 1
              color: ColorService.colorPalette.textPrimary
              visible: modelData.checkState === Qt.Checked
            }
          }
          
          // Icon
          Image {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            
            source: modelData.icon
            sourceSize.width: 20
            sourceSize.height: 20
            visible: modelData.icon !== ""
            fillMode: Image.PreserveAspectFit
          }
          
          // Text
           Text {
            Layout.maximumWidth: 180
            Layout.alignment: Qt.AlignVCenter
            text: modelData.text
            color: ColorService.colorPalette.textPrimary
            font.family: Settings.config.fonts.primary
            font.pixelSize: Ui.tokens.fontSize.sm
            wrapMode: Text.WordWrap
            elide: Text.ElideLeft
          }
          
          // Submenu indicator
          Text {
            Layout.alignment: Qt.AlignVCenter
            text: "›"
            color: ColorService.colorPalette.textSecondary
            font.pixelSize: 16
            visible: modelData.hasChildren
          }
        }
        
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          enabled: !modelData.isSeparator && modelData.enabled
          
          onClicked: {
            if (modelData.hasChildren) {
              // Open submenu if it has children
              modelData.display(root, mouse.x, mouse.y)
            } else {
              // Trigger the menu action
              modelData.triggered()
              root.closeWindow()
            }
          }
        }
      }
    }
  }
}
