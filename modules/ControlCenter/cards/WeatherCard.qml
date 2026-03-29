pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets
import qs.assets
import qs.config

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(ColorService.colorPalette.backgroundPrimary_300.r, ColorService.colorPalette.backgroundPrimary_300.g, ColorService.colorPalette.backgroundPrimary_300.b, 0.2)
        radius: Ui.tokens.spacing.md + Ui.tokens.spacing.sm

        border {
            width: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.2)
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: Ui.tokens.spacing.sm
        }

        Item {
            id: current
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 80
            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(ColorService.colorPalette.backgroundPrimary_100, 0.2)
                radius: Ui.tokens.spacing.md
            }
            ColumnLayout {
                anchors {
                    fill: parent
                    leftMargin: Ui.tokens.spacing.md
                }
                RowLayout {
                    Layout.fillWidth: true
                    Column {
                        RavenText {
                            text: `${WeatherService.currentTemp}°`
                            fontSize: 24
                        }
                        RavenText {
                            text: "Tirana, Albania"
                            opacity: 0.7
                        }
                        RavenText {
                            text: WeatherService.weatherDescription
                            color: ColorService.colorPalette.accentPrimary
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: 100
            clip: true

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(ColorService.colorPalette.backgroundPrimary_100, 0.2)
                radius: Ui.tokens.spacing.md
            }
            ListView {
                id: hourlyList
                anchors {
                    fill: parent
                    margins: Ui.tokens.spacing.sm
                }
                Layout.maximumHeight: 80
                orientation: ListView.Horizontal
                spacing: 4
                clip: true
                interactive: true
                model: WeatherService.hourModel

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    radius: 10
                    implicitWidth: 45
                    implicitHeight: hourlyList.height
                    color: index === 0 ? ColorService.colorPalette.accentPrimary : Qt.alpha(ColorService.colorPalette.backgroundPrimary_100, 0.2)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 0

                        RavenText {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.hourTime
                            opacity: 0.8
                            fontSize: 9
                        }

                        IconImage {
                            Layout.alignment: Qt.AlignHCenter
                            implicitSize: 24
                            source: Quickshell.iconPath(modelData.icon)
                        }

                        RavenText {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.temperature + "°"
                            fontSize: 13
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 3
                            opacity: 0.8
                            RavenIcon {
                                iconName: Icons.weather.drop
                                iconSize: 10
                            }
                            RavenText {
                                text: modelData.humidity + "%"
                                fontSize: 10
                            }
                        }
                    }
                }
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(ColorService.colorPalette.backgroundPrimary_100, 0.2)
                radius: Ui.tokens.spacing.md
            }
            ListView {
                id: dailyList
                anchors {
                    fill: parent
                    margins: Ui.tokens.spacing.sm
                }
                spacing: 0
                interactive: true
                model: WeatherService.dailyModel
                delegate: Rectangle {
                    required property var modelData
                    implicitHeight: 25
                    implicitWidth: dailyList.width
                    radius: 8
                    color: modelData.index === 0 ? ColorService.colorPalette.accentPrimary : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Ui.tokens.spacing.sm
                        anchors.rightMargin: Ui.tokens.spacing.sm

                        RavenText {
                            text: modelData.dayName
                            fontSize: 10
                            font.weight: modelData.index === 0 ? Font.DemiBold : Font.Normal
                            Layout.preferredWidth: 50
                        }
                        Item {
                          Layout.fillWidth: true
                        }
                        RowLayout {
                          spacing: Ui.tokens.spacing.md
                            IconImage {
                                implicitSize: 24
                                source: Quickshell.iconPath(modelData.icon)
                            }
                            RavenText {
                                opacity: modelData.index === 0 ? 1.0 : 0.8
                                fontSize: 10
                                font.weight: modelData.index === 0 ? Font.Medium : Font.Normal
                                text: `${modelData.maxTemp}°`
                                Layout.preferredWidth: 16
                            }

                            RavenText {
                                opacity: modelData.index === 0 ? 1.0 : 0.8
                                fontSize: 10
                                font.weight: modelData.index === 0 ? Font.Medium : Font.Normal
                                text: `${modelData.minTemp}°`
                                Layout.preferredWidth: 16

                            }
                        }
                    }
                }
            }
        }
    }
}
