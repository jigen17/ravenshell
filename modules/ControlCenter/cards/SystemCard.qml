import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    readonly property color backgroundColor: Qt.rgba(ColorService.colorPalette.backgroundSecondary_300.r, ColorService.colorPalette.backgroundSecondary_300.g, ColorService.colorPalette.backgroundSecondary_300.b, 0.2)

    spacing: 8

    // ── CPU + RAM row ─────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        spacing: 8

        // CPU
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.backgroundColor
            radius: 12

            ColumnLayout {
                spacing: 6

                anchors {
                    fill: parent
                    margins: 10
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    RavenText {
                        text: "CPU"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        opacity: 0.5
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RavenText {
                        text: `${Math.floor(ResourceService.cpuUsage * 100)}%`
                        font.pixelSize: 13
                        color: ColorService.colorPalette.accentPrimary
                    }

                    RavenText {
                        text: `${ResourceService.temperature.toFixed(1)}°C`
                        font.pixelSize: 11
                        color: {
                            const t = ResourceService.temperature;
                            return t > 80 ? "#f87171" : t > 70 ? "#fb923c" : ColorService.colorPalette.textPrimary;
                        }
                        opacity: 0.7
                    }

                }

                RavenGraph {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: ResourceService.cpuUsage
                    backgroundColor: "transparent"
                    strokeColor: ColorService.colorPalette.accentPrimary
                    fillColor: Qt.rgba(ColorService.colorPalette.accentPrimary.r, ColorService.colorPalette.accentPrimary.g, ColorService.colorPalette.accentPrimary.b, 0.12)
                }

                RavenText {
                    text: "i7-6600U · 2C / 4T"
                    font.pixelSize: 10
                    opacity: 0.3
                }

            }

        }

        // RAM
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.backgroundColor
            radius: 12

            ColumnLayout {
                spacing: 6

                anchors {
                    fill: parent
                    margins: 10
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    RavenText {
                        text: "Memory"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        opacity: 0.5
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RavenText {
                        text: `${Math.floor(ResourceService.memUsage * 100)}%`
                        color: ColorService.colorPalette.accentSecondary
                    }

                    RavenText {
                        text: `${(ResourceService.memFree / 1024 / 1024).toFixed(1)}G free`
                        opacity: 0.5
                    }

                }

                RavenGraph {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: ResourceService.memUsage
                    backgroundColor: "transparent"
                    strokeColor: ColorService.colorPalette.accentSecondary
                    fillColor: Qt.rgba(ColorService.colorPalette.accentSecondary.r, ColorService.colorPalette.accentSecondary.g, ColorService.colorPalette.accentSecondary.b, 0.12)
                }

                RavenText {
                    text: `${(ResourceService.memTotal / 1024 / 1024).toFixed(1)} GB`
                    font.pixelSize: 10
                    opacity: 0.3
                }

            }

        }

    }

    // ── GPU + Disk + Net row ──────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        spacing: 8

        // GPU
        Rectangle {
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            color: root.backgroundColor
            radius: 12

            ColumnLayout {
                spacing: 0

                anchors {
                    fill: parent
                    margins: 10
                }

                RavenText {
                    text: "GPU"
                    font.pixelSize: 11
                    opacity: 0.5
                }

                RavenCircularProgress {
                    progress: ResourceService.cpuUsage
                    Layout.alignment: Qt.AlignCenter
                    implicitWidth: 80

                    centerItem: RavenText {
                        text: `${Math.floor(ResourceService.gpuUsage * 100)}%`
                        font.pixelSize: 13
                        color: "#fb923c"
                    }

                }

                RavenText {
                    text: "HD Graphics 520"
                    font.pixelSize: 10
                    opacity: 0.3
                }

            }

        }

        // Disk
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.backgroundColor
            radius: 12

            ColumnLayout {
                spacing: 4

                anchors {
                    fill: parent
                    margins: 10
                }

                RavenText {
                    text: "Disk"
                    font.pixelSize: 11
                    opacity: 0.5
                }

                RowLayout {
                    Layout.fillWidth: true

                    RavenText {
                        text: "nvme"
                        font.pixelSize: 11
                        opacity: 0.45
                    }

                    RavenProgress {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        value: ResourceService.nvmeUsage
                    }

                    RavenText {
                        text: `${Math.floor(ResourceService.nvmeUsage * 100)}%`
                        color: ColorService.colorPalette.accentSecondary
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    RavenText {
                        text: "sda"
                        font.pixelSize: 11
                        opacity: 0.45
                    }

                    RavenProgress {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        value: ResourceService.sdaUsage
                    }

                    RavenText {
                        text: `${Math.floor(ResourceService.sdaUsage * 100)}%`
                        font.pixelSize: 12
                        color: ColorService.colorPalette.accentSecondary
                        opacity: 0.7
                    }

                }

            }

        }

        // Network
        Rectangle {
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            color: root.backgroundColor
            radius: 12

            ColumnLayout {
                spacing: 4

                anchors {
                    fill: parent
                    margins: 10
                }

                RavenText {
                    text: "Network"
                    font.pixelSize: 11
                    opacity: 0.5
                }

                RowLayout {
                    Layout.fillWidth: true

                    RavenText {
                        text: "↑"
                        font.pixelSize: 16
                        opacity: 0.45
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RavenText {
                        text: `${ResourceService.upSpeed}`
                        color: ColorService.colorPalette.accentPrimary
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    RavenText {
                        text: "↓"
                        font.pixelSize: 16
                        opacity: 0.45
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RavenText {
                        text: `${ResourceService.downSpeed}`
                        color: ColorService.colorPalette.accentSecondary
                    }

                }

            }

        }

    }

}
