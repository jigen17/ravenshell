import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    //radius: 18
    //color: ColorService.colorPalette.backgroundPrimary
    clip: true

    ListView {
        id: listItem

        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
        orientation: ListView.Horizontal
        spacing: 8
        clip: true
        interactive: true
        model: WeatherService.hourModel
        Component.onCompleted: {
            positionViewAtIndex(0, ListView.Beginning);
        }

        delegate: Rectangle {
            radius: 12
            implicitWidth: 145
            implicitHeight: listItem.height
            color: index === 0 ? ColorService.colorPalette.accentPrimary : ColorService.colorPalette.backgroundSecondary_300

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                RavenText {
                    Layout.alignment: Qt.AlignHCenter
                    text: model.hourTime
                    opacity: 0.8
                    fontSize: 10
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        IconImage {
                            Layout.alignment: Qt.AlignHCenter
                            implicitSize: 48
                            source: Quickshell.iconPath(model.icon)
                        }

                        RavenText {
                            Layout.alignment: Qt.AlignHCenter
                            text: model.temperature + "°"
                            fontSize: 16
                        }

                    }

                    ColumnLayout {
                        Layout.fillHeight: true
                        spacing: 10

                        RowLayout {
                            spacing: 4
                            opacity: 0.8

                            RavenIcon {
                                iconName: Icons.weather.drop
                                iconSize: 12
                                Layout.alignment: Qt.AlignVCenter
                            }

                            RavenText {
                                text: model.humidity + "%"
                                fontSize: 12
                            }

                        }

                        RowLayout {
                            spacing: 4
                            opacity: 0.8

                            RavenIcon {
                                iconName: Icons.weather.wind
                                iconSize: 12
                            }

                            RavenText {
                                text: model.windSpeed + " km/h"
                                fontSize: 12
                            }

                        }

                        RowLayout {
                            spacing: 4
                            opacity: 0.8

                            RavenIcon {
                                iconName: Icons.weather.umbrella
                                iconSize: 12
                            }

                            RavenText {
                                text: model.precipitation + "%"
                                fontSize: 12
                            }

                        }

                    }

                }

            }

        }

    }

}
