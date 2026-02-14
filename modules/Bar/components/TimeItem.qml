import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

Rectangle {
    id: root
    implicitHeight: 30
    implicitWidth: 140
    color: Qt.rgba(ColorService.colorPalette.accentPrimary.r, ColorService.colorPalette.accentPrimary.g, ColorService.colorPalette.accentPrimary.b, 0.5)
    radius: 12

    RowLayout {
        id: timeColumn
        anchors.centerIn: parent
        spacing: 8

        Row {
            spacing: 2
            Layout.fillWidth: true
            RavenText {
                text: TimeService.hourString
                font.family: "Nunito Heavy"
                font.bold: true
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: implicitWidth
            }

            RavenText {
                text: ":"
                font.family: "Nunito Heavy"

                font.bold: true
            }

            RavenText {
                text: TimeService.minuteString
                font.family: "Nunito Heavy"

                font.bold: true
                horizontalAlignment: Text.AlignLeft
                Layout.preferredWidth: implicitWidth
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            color: ColorService.colorPalette.accentPrimary
            opacity: 0.5
        }

        Row {
            spacing: 4
            Layout.preferredWidth: 50

            IconImage {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                source: Quickshell.iconPath(WeatherService.currentWeatherIcon)
            }

            RavenText {
                anchors.verticalCenter: parent.verticalCenter
                text: WeatherService.currentTemp + " °C"
                font.family: "Nunito Heavy"

                font.bold: true
                horizontalAlignment: Text.AlignLeft
            }
        }
    }
}
