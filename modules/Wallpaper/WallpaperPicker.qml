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
        name: "wallpaperPicker"
        onPressed: root.toggleWindow()
    }

    IpcHandler {
        target: "wallpaperPicker"
        function open() {
            root.openWindow();
        }
    }
    panelWidth: 1200
    panelHeight: 320
    animationType: 2
    anchorPosition: "bottom"
    keyboardFocus: true
    margins: 20
    cornerRadius: 42
    contentItem: ColumnLayout {
        spacing: Ui.tokens.spacing.md
        focus: true

        Connections {
            target: root
            function onOpened() {
                // Position to current wallpaper when opening
                if (wallpaperList.count > 0) {
                    const idx = WallpaperService.filteredWallpaperList.indexOf(WallpaperService.currentWallpaper);
                    if (idx >= 0) {
                        wallpaperList.currentIndex = idx;
                        // Force immediate positioning without animation
                    }
                }
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
            model: WallpaperService.filteredWallpaperList

            preferredHighlightBegin: width / 2 - 250
            preferredHighlightEnd: width / 2 + 250
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapToItem

            // Keyboard navigation
            Keys.onLeftPressed: decrementCurrentIndex();
            Keys.onRightPressed: incrementCurrentIndex()
            Keys.onUpPressed: incrementCurrentIndex()
            Keys.onDownPressed: decrementCurrentIndex()
            Keys.onEscapePressed: root.closeWindow()
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    if (currentItem) {
                        WallpaperService.setWallpaper(currentItem.modelData);
                        root.closeWindow();
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Home) {
                    currentIndex = 0;
                    event.accepted = true;
                } else if (event.key === Qt.Key_End) {
                    currentIndex = count - 1;
                    event.accepted = true;
                }
            }

            delegate: ClippingRectangle {
                id: wallItem
                required property string modelData
                required property int index

                readonly property bool isCurrent: ListView.isCurrentItem
                readonly property bool isCurrentWallpaper: modelData === WallpaperService.currentWallpaper

                implicitWidth: 500
                implicitHeight: wallpaperList.height 
                radius: 22
                smooth: true
                antialiasing: true
                // Elevation effect for current item
                opacity: isCurrent ? 1.0 : 0.8
                scale: isCurrent ? 1.0 : 0.9
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                  }
                Image {
                    anchors.fill: parent
                    source: wallItem.modelData
                    asynchronous: true
                    antialiasing: true
                    cache: true
                    smooth: true
                }
                // Filename overlay
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    implicitHeight: 40
                    bottomLeftRadius: 12
                    bottomRightRadius: 12
                    color: Qt.rgba(0, 0, 0, 0.75)
                    opacity: wallItem.isCurrent ? 1 : 0.6

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: wallItem.modelData.split("/").pop()
                        color: "white"
                        font.pixelSize: 13
                        elide: Text.ElideMiddle
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        wallpaperList.currentIndex = wallItem.index;
                        WallpaperService.setWallpaper(wallItem.modelData);
                        root.closeWindow();
                    }
                }
            }
        }

        // Keyboard hints overlay
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: navText.implicitWidth * 1.2
            Layout.preferredHeight: 30
            radius: 15
            color: Qt.rgba(0, 0, 0, 0.6)

            Text {
                id: navText
                anchors.centerIn: parent
                text: "← → Navigate  |  Enter Select  |  Home/End Jump  |  Esc Close"
                color: "#cccccc"
                font.pixelSize: 12
            }
        }
    }
}
