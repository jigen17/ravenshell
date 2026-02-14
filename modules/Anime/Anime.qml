pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

StyledPanel {
    id: root

    KeyboardShortcut {
        name: "animePicker"
        onPressed: root.toggleWindow()
    }

    panelWidth: 1500
    panelHeight: 500
    animationType: 2
    anchorPosition: "bottom"
    keyboardFocus: true
    margins: 20
    cornerRadius: 42
    contentItem: ColumnLayout {
        spacing: Ui.tokens.spacing.md
        focus: true
        Component.onCompleted: AnimeService.search("Naruto")
        Connections {
            target: root
            function onOpened() {
                // Position to current wallpaper when opening
                wallpaperList.forceActiveFocus();
            }
        }
        ListView {
            id: wallpaperList
            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: ListView.Horizontal
            spacing: 20
            clip: true
            focus: true
            focusPolicy: Qt.StrongFocus
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 300
            highlightMoveVelocity: -1
            model: AnimeService.results
            preferredHighlightBegin: width / 2 - 250
            preferredHighlightEnd: width / 2 + 250
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapToItem

            Keys.onLeftPressed: decrementCurrentIndex()
            Keys.onRightPressed: incrementCurrentIndex()
            Keys.onUpPressed: incrementCurrentIndex()
            Keys.onDownPressed: decrementCurrentIndex()
            Keys.onEscapePressed: root.closeWindow()
            delegate: ClippingRectangle {
                required property var modelData
                implicitHeight: wallpaperList.height
                implicitWidth: 400
                color: ListView.isCurrentItem ? ColorService.colorPalette.accentPrimary : ColorService.colorPalette.backgroundSecondary_300
                radius: 18
                Behavior on color {
                    ColorAnimation {
                        duration: 240
                        easing.type: Easing.OutInQuad
                    }
                }
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20
                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: wallpaperList.height / 2
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        cache: true
                        source: modelData.cover
                        //                        fillMode: Image.PreserveAspectCrop
                    }
                    RavenText {
                        font.family: "Nunito Heavy"
                        text: modelData.title
                        Layout.maximumWidth: 380
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        wrapMode: Text.WordWrap
                        elide: Text.ElideMiddle
                        fontSize: 20
                        textColor: "#000"
                    }

                    FlexboxLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.margins: 5
                        gap: 8
                        wrap: FlexboxLayout.Wrap

                        Repeater {
                            model: modelData.genres ? modelData.genres.split(",") : []

                            Rectangle {
                                required property string modelData
                                required property int index

                                implicitWidth: 80
                                implicitHeight: 30
                                radius: 6
                                color: ColorService.colorPalette.accentonPrimary

                                RavenText {
                                    id: genreText
                                    anchors.centerIn: parent
                                    text: modelData  // Now this will be "Action", "Drama", etc!
                                    fontSize: 10
                                    color: "#000"
                                }
                            }
                        }
                    }
                    RavenText {
                        text: modelData.description
                        Layout.maximumWidth: 380
                        Layout.alignment: Qt.AlignHCenter || Qt.AlignTop
                        horizontalAlignment: Qt.AlignHCenter
                        wrapMode: Text.WordWrap
                        elide: Text.ElideMiddle
                        fontSize: 10
                        textColor: "#000"
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
