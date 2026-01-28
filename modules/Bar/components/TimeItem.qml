import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.widgets

Rectangle {
    id: root
    implicitWidth: 30
    implicitHeight: timeColumn.implicitHeight * 1.2
    color: ColorService.colorPalette.backgroundSecondary_300
    radius: width / 3
    ColumnLayout {
        id: timeColumn
        anchors.centerIn: parent

        RavenText {
            text: TimeService.hourString
            font.bold: true
        }
        RavenText {
            text: TimeService.minuteString
            font.bold: true
        }
    }
}
