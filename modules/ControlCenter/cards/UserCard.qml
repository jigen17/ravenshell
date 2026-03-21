import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.config
import qs.widgets
import qs.assets

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: ColorService.colorPalette.backgroundSecondary
        radius: 18
    }

    RowLayout {
      spacing: Ui.tokens.spacing.sm
        anchors {
            fill: parent
            margins: 20
        }

        ClippingRectangle {
            implicitWidth: 40
            implicitHeight: 40
            radius: height / 2
            color: "transparent"
            border {
                color: ColorService.colorPalette.accentPrimary
                width: 1
            }
            Image {
                anchors.fill: parent
                smooth: true
                cache: true
                antialiasing: true
                source: "/home/mikaelio/.face.icon"
            }
        }

        Column {
          Layout.alignment: Qt.AlignVCenter
          Layout.fillWidth: true
            RavenText {
                text: "Hey,Mikaelio!"
                font.bold: true
            }
        }

        ButtonIcon {
            iconName: Icons.settings.gearsix
        }
        ButtonIcon {
            iconName: Icons.power.shutdown
        }
    }
}
