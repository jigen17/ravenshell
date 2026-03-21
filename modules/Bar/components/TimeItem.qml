import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root
    implicitHeight: 30
    implicitWidth: 140

    // Background
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(ColorService.colorPalette.accentPrimary.r, ColorService.colorPalette.accentPrimary.g, ColorService.colorPalette.accentPrimary.b, 0.5)
    }

    // Content
    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
        }

        // Time display
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 4
            RavenText {
                text: TimeService.hourString
            }
            RavenText {
                text: ":"
            }
            RavenText {
                text: TimeService.minuteString
            }
        }
        Item {
            Layout.fillWidth: true
        }
        // Separator
        Rectangle {
            implicitWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            Layout.alignment: Qt.AlignCenter
            color: ColorService.colorPalette.accentPrimary
            opacity: 0.5
        }
        Item {
            Layout.fillWidth: true
        }
        // Weather display
        RowLayout {
          Layout.fillWidth: true
            spacing: 6

            IconImage {
                implicitSize: 22
                source: Quickshell.iconPath(WeatherService.currentWeatherIcon)
            }

            RavenText {
                Layout.preferredWidth: 25
                text: WeatherService.currentTemp + "°C"
            }
        }
    }
}
