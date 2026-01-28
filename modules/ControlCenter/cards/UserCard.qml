import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.config
import qs.widgets
import qs.assets

Rectangle {
    id: root
    color: ColorService.colorPalette.backgroundSecondary_300
    RowLayout {
        id: userRow
        anchors {
          fill: parent
          margins: Ui.tokens.spacing.md 
          }
          spacing: Ui.tokens.spacing.sm
        ClippingRectangle {
            implicitWidth: 40
            implicitHeight: 40
            radius: height / 2
            color: "transparent"
            border {
                color: ColorService.colorPalette.accentPrimary
                width: 2
            }
            Image {
                anchors.fill: parent
                smooth: true
                cache: true
                antialiasing: true
                source: "/home/mikaelio/.face.icon"
            }
        }

        RavenText {
          text: "Hey,Mikaelio!"
          font.bold: true
        }

        Item {
            Layout.fillWidth: true
        }
        Row {
          spacing: 10
            ButtonIcon {
                iconName: Icons.settings.gearsix
            }
            ButtonIcon {
                iconName: Icons.power.shutdown
            }
        }
    }
}
