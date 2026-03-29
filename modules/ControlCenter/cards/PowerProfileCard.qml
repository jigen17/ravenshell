import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(ColorService.colorPalette.backgroundPrimary_300.r, ColorService.colorPalette.backgroundPrimary_300.g, ColorService.colorPalette.backgroundPrimary_300.b, 0.2)
        radius: 12

        border {
            width: 1
            color: Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.2)
        }

    }

    RowLayout {
        spacing: 4

        anchors {
            fill: parent
            margins: Ui.tokens.spacing.sm
        }

        Repeater {
            model: [{
                "icon": Icons.powerProfile.powerSave,
                "label": "Saver",
                "profile": 0
            }, {
                "icon": Icons.powerProfile.balanced,
                "label": "Balanc",
                "profile": 1
            }, {
                "icon": Icons.powerProfile.performance,
                "label": "Perf",
                "profile": 2
            }]

            delegate: Rectangle {
                readonly property bool isActive: UpowerService.powerProfile === modelData.profile
                readonly property bool isHovered: mouseArea.containsMouse

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: isActive ? Qt.rgba(ColorService.colorPalette.accentPrimary.r, ColorService.colorPalette.accentPrimary.g, ColorService.colorPalette.accentPrimary.b, 0.55) : isHovered ? Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.08) : "transparent"

                border {
                    width: isActive ? 1 : 0
                    color: Qt.rgba(ColorService.colorPalette.accentPrimary.r, ColorService.colorPalette.accentPrimary.g, ColorService.colorPalette.accentPrimary.b, 0.9)
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 3

                    RavenIcon {
                        Layout.alignment: Qt.AlignHCenter
                        iconName: modelData.icon
                        iconColor: isActive ? ColorService.colorPalette.textPrimary : Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.4)

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                    RavenText {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.label
                        fontSize: 10
                        color: isActive ? ColorService.colorPalette.textPrimary : Qt.rgba(ColorService.colorPalette.textPrimary.r, ColorService.colorPalette.textPrimary.g, ColorService.colorPalette.textPrimary.b, 0.4)

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UpowerService.toggleProfile(modelData.profile)
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

    }

}
