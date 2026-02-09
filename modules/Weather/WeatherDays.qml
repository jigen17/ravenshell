import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets
import qs.assets
import qs.config

Rectangle {
    id: root
    radius: 18
    color: ColorService.colorPalette.backgroundSecondary

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Ui.tokens.spacing.sm
        spacing: 0
        Repeater {
            model: WeatherService.dailyModel
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 25
                radius: 10
                color: modelData.index === 0 ? ColorService.colorPalette.accentPrimary : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Ui.tokens.spacing.sm
                    anchors.rightMargin: Ui.tokens.spacing.sm
                    spacing: Ui.tokens.spacing.sm

                    RavenText {
                        text: modelData.dayName
                        fontSize: 10
                        font.weight: modelData.index === 0 ? Font.DemiBold : Font.Normal
                        Layout.preferredWidth: 50
                    }

                    IconImage {
                        implicitSize: 24
                        source: Quickshell.iconPath(modelData.icon)
                    }
                    RowLayout {
                      Layout.preferredWidth: 50
                        RavenText {
                            opacity: modelData.index === 0 ? 1.0 : 0.8
                            fontSize: 10
                            font.weight: modelData.index === 0 ? Font.Medium : Font.Normal
                            text: `${modelData.maxTemp}°`
                        }

                        RavenText {
                            opacity: modelData.index === 0 ? 1.0 : 0.8
                            fontSize: 10
                            font.weight: modelData.index === 0 ? Font.Medium : Font.Normal
                            text: `${modelData.minTemp}°`
                        }
                    }
                }
            }
        }
    }
}
