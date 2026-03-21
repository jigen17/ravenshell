pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.assets
import qs.config
import qs.services
import qs.widgets

StyledPanel {
    //WallpaperService.results.count > 0

    id: root

    readonly property int thumbW: 180
    readonly property int thumbH: 150
    readonly property int gap: 5
    property string searchText: ""
    // ── helpers ───────────────────────────────────────────────
    property bool isOnlineMode: false

    panelWidth: 800
    panelHeight: 450
    animationType: 1
    anchorPosition: "top"
    keyboardFocus: true
    margins: 20
    cornerRadius: 28

    KeyboardShortcut {
        name: "wallpaperPicker"
        onPressed: root.toggleWindow()
    }

    IpcHandler {
        function open() {
            root.openWindow();
        }

        target: "wallpaperPicker"
    }

    contentItem: ColumnLayout {
        function applyCurrentItem() {
            if (root.isOnlineMode) {
                const item = WallpaperService.results.get(gridView.currentIndex);
                if (item)
                    WallpaperService.downloadAndApply(item.path);

            } else {
                const path = wallModel.values[gridView.currentIndex];
                if (path)
                    WallpaperService.setWallpaper(path);

            }
        }

        spacing: root.gap

        Connections {
            function onOpened() {
                searchField.text = "";
                searchField.forceActiveFocus();
                const idx = wallModel.values.indexOf(WallpaperService.currentWallpaper);
                if (idx >= 0)
                    gridView.currentIndex = idx;

            }

            function onClosed() {
                WallpaperService.clearListModel();
            }
            function isOnlineModeChanged() {
              WallpaperService.clearListModel();
            }
            target: root
        }

        ScriptModel {
            id: wallModel

            values: {
                const q = root.searchText.toLowerCase();
                return WallpaperService.filteredWallpaperList.filter((p) => {
                    return p.split("/").pop().toLowerCase().includes(q);
                });
            }
        }
        // ── search bar ───────────────────────────────────────

        Item {
            Layout.fillWidth: true
            implicitHeight: 34

            RowLayout {
                spacing: 6

                anchors {
                    fill: parent
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 35

                    Rectangle {
                        anchors.fill: parent
                        color: ColorService.colorPalette.backgroundSecondary
                        radius: 10

                        border {
                            width: 2
                            color: ColorService.colorPalette.accentPrimary
                        }

                    }

                    TextInput {
                        id: searchField

                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        color: ColorService.colorPalette.textPrimary
                        font.family: Settings.config.fonts.monoSpace
                        font.pixelSize: Ui.tokens.fontSize.md
                        clip: true
                        onTextChanged: root.searchText = text
                        Keys.onEscapePressed: text.length > 0 ? clear() : root.closeWindow()
                        Keys.onLeftPressed: gridView.moveCurrentIndexLeft()
                        Keys.onRightPressed: gridView.moveCurrentIndexRight()
                        Keys.onUpPressed: gridView.moveCurrentIndexUp()
                        Keys.onDownPressed: gridView.moveCurrentIndexDown()
                        Keys.onReturnPressed: WallpaperService.searchWallpapers(text)

                        anchors {
                            fill: parent
                            margins: 10
                        }

                    }

                }

                ButtonIcon {
                  iconName: Icons.internet.globe
                  buttonPadding: 10
                  enabled: root.isOnlineMode
                  onClicked: root.isOnlineMode =!root.isOnlineMode
                }
            }

        }

        // ── grid ─────────────────────────────────────────────
        GridView {
            id: gridView

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            clip: true
            focus: true
            model: root.isOnlineMode ? WallpaperService.results : wallModel.values
            cellWidth: width / 4 
            cellHeight: root.thumbH + root.gap
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 200
            // ── infinite scroll ───────────────────────────────
            onContentYChanged: {
                const threshold = contentHeight - height * 1.5;
                if (contentY >= threshold)
                    WallpaperService.fetchNextPage();

            }
            Keys.onEscapePressed: root.closeWindow()
            Keys.onReturnPressed: applyCurrentItem()

            delegate: ClippingRectangle {
                required property var modelData
                required property int index
                readonly property bool isCurrent: GridView.isCurrentItem
                readonly property bool isActive: modelData === WallpaperService.currentWallpaper

                implicitWidth: gridView.cellWidth - root.gap
                implicitHeight: root.thumbH
                radius: 12
                smooth: true
                antialiasing: true
                color: Qt.rgba(1, 1, 1, 0.5)
                border.width: isCurrent ? 2 : 0
                border.color: ColorService.colorPalette.accentonPrimary

                // ── loading skeleton ──────────────────────────
                Item {
                    anchors.fill: parent
                    visible: img.status !== Image.Ready

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Repeater {
                            model: 3

                            delegate: Rectangle {
                                id: ball
                                required property int index

                                width: 5
                                height: 5
                                radius: 3
                                color: ColorService.colorPalette.accentonPrimary

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: img.status !== Image.Ready

                                    PauseAnimation {
                                        duration: ball.index * 160
                                    }

                                    NumberAnimation {
                                        from: 0.2
                                        to: 1
                                        duration: 300
                                        easing.type: Easing.OutCubic
                                    }

                                    NumberAnimation {
                                        from: 1
                                        to: 0.2
                                        duration: 300
                                        easing.type: Easing.InCubic
                                    }

                                    PauseAnimation {
                                        duration: (2 - ball.index) * 160
                                    }

                                }

                            }

                        }

                    }

                }

                // ── image ─────────────────────────────────────
                Image {
                    id: img

                    anchors.fill: parent
                    source: root.isOnlineMode ? modelData.thumbnail : modelData
                    asynchronous: true
                    cache: true
                    smooth: true
                    mipmap: true
                    fillMode: Image.PreserveAspectCrop
                    opacity: status === Image.Ready ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                // ── active badge ───────────────────────────────
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: "#E8834A"
                    visible: isActive

                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 6
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        color: "white"
                        font.pixelSize: 10
                        font.bold: true
                    }

                }

                // ── label ─────────────────────────────────────
                Rectangle {
                    implicitHeight: 32
                    bottomLeftRadius: 10
                    bottomRightRadius: 10
                    color: Qt.rgba(0, 0, 0, 0.7)
                    opacity: isCurrent ? 1 : 0.5

                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    RavenText {
                        text: root.isOnlineMode ? modelData.resolution : modelData.split("/").pop()
                        color: "white"
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSize: 18

                        anchors {
                            fill: parent
                            margins: 8
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                // ── mouse interaction ──────────────────────────
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        gridView.currentIndex = index;
                        applyCurrentItem();
                    }
                }

                NumberAnimation on border.width {
                    duration: 180
                    easing.type: Easing.OutCubic
                }

                ColorAnimation on border.color {
                    duration: 180
                    easing.type: Easing.OutCubic
                }

            }

        }

        // ── hint ─────────────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "← → ↑ ↓ Navigate  ·  Enter Apply  ·  Esc Close"
            color: Qt.rgba(1, 1, 1, 0.2)
            font.pixelSize: 11
        }

    }

}
