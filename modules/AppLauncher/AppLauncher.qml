import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.assets
import qs.config
import qs.services
import qs.widgets

StyledPanel {
    id: root

    animationType: 0
    anchorPosition: "center"
    keyboardFocus: true
    panelWidth: 800
    panelHeight: 500
    cornerRadius: 38
    margins: 20

    KeyboardShortcut {
        name: "appLauncher"
        onPressed: root.toggleWindow()
    }
    // Content

    contentItem: RowLayout {
        id: contentRow

        anchors.centerIn: parent
        focus: true

        Connections {
            function onOpened() {
                // Delay focus to ensure window has keyboard focus
                Qt.callLater(() => {
                    searchField.forceActiveFocus();
                });
            }

            function onClosed() {
                AppService.clearSearch();
            }

            target: root
        }
        // Category sidebar

        Rectangle {
            Layout.preferredWidth: 30 + Ui.tokens.spacing.md * 2
            Layout.fillHeight: true
            color: Qt.rgba(ColorService.colorPalette.accentonPrimary.r, ColorService.colorPalette.accentonPrimary.g, ColorService.colorPalette.accentonPrimary.b, 0.7)
            radius: 18
            focus: false

            ColumnLayout {
                spacing: Ui.tokens.spacing.sm

                anchors {
                    fill: parent
                    margins: Ui.tokens.spacing.sm
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.layouts.grid_squares
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.clearCategory()
                    enabled: AppService.selectedCategory === ""
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.development.code
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("Development")
                    enabled: AppService.selectedCategory === "Development"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.devices.game_controller
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("Game")
                    enabled: AppService.selectedCategory === "Game"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.media.palette
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("Graphics")
                    enabled: AppService.selectedCategory === "Graphics"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.internet.globe
                    iconSize: Ui.tokens.iconSize.md
                    onClicked: AppService.setCategory("Network")
                    buttonPadding: Ui.tokens.spacing.sm
                    enabled: AppService.selectedCategory === "Network"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.media.film_strip
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("AudioVideo")
                    enabled: AppService.selectedCategory === "AudioVideo"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.office.notepad
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("Office")
                    enabled: AppService.selectedCategory === "Office"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.settings.gear
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("Settings")
                    enabled: AppService.selectedCategory === "Settings"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.utilities.toolbox
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("Utility")
                    enabled: AppService.selectedCategory === "Utility"
                }

                ButtonIcon {
                    Layout.alignment: Qt.AlignHCenter
                    iconName: Icons.help.info
                    iconSize: Ui.tokens.iconSize.md
                    buttonPadding: Ui.tokens.spacing.sm
                    onClicked: AppService.setCategory("System")
                    enabled: AppService.selectedCategory === "System"
                }

            }

        }

        // Main content area
        ColumnLayout {
            id: mainContent

            function launchCurrentApp() {
                if (appGrid.count > 0 && appGrid.currentIndex >= 0) {
                    const delegate = appGrid.itemAtIndex(appGrid.currentIndex);
                    if (delegate && delegate.runApp)
                        delegate.runApp();

                }
            }

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Ui.tokens.spacing.sm
            spacing: Ui.tokens.spacing.lg
            focus: true

            // Search bar
            TextField {
                id: searchField

                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignTop
                padding: Ui.tokens.spacing.md
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: Ui.tokens.fontSize.md
                font.family: Settings.config.fonts.primary
                color: ColorService.colorPalette.textSecondary
                focus: true
                placeholderText: "Search applications..."
                placeholderTextColor: Qt.rgba(ColorService.colorPalette.textSecondary.r, ColorService.colorPalette.textSecondary.g, ColorService.colorPalette.textSecondary.b, 0.4)
                onTextChanged: {
                    AppService.searchApplications(text);
                    if (appGrid.count > 0)
                        appGrid.currentIndex = 0;

                }
                Keys.onEscapePressed: root.closeWindow()
                Keys.onDownPressed: {
                    if (appGrid.count > 0)
                        appGrid.moveCurrentIndexDown();

                }
                Keys.onUpPressed: {
                    appGrid.moveCurrentIndexUp();
                }
                Keys.onLeftPressed: {
                    if (cursorPosition === text.length && appGrid.count > 0)
                        appGrid.moveCurrentIndexLeft();

                }
                Keys.onRightPressed: {
                    if (cursorPosition === text.length && appGrid.count > 0)
                        appGrid.moveCurrentIndexRight();

                }
                Keys.onReturnPressed: {
                    if (appGrid.count > 0 && appGrid.currentIndex >= 0)
                        mainContent.launchCurrentApp();

                }

                background: Rectangle {
                    color: ColorService.colorPalette.backgroundSecondary_700
                    border.width: 2
                    border.color: searchField.activeFocus ? ColorService.colorPalette.accentPrimary : Qt.rgba(ColorService.colorPalette.accentPrimary.r, ColorService.colorPalette.accentPrimary.g, ColorService.colorPalette.accentPrimary.b, 0.3)
                    radius: 12

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: appGrid

                    anchors.fill: parent
                    cellWidth: width / 5
                    cellHeight: cellWidth
                    model: AppService.searchResults
                    clip: true
                    currentIndex: 0
                    keyNavigationEnabled: true
                    highlightFollowsCurrentItem: true
                    onCurrentIndexChanged: {
                        positionViewAtIndex(currentIndex, GridView.Contain);
                    }
                    Keys.onEscapePressed: {
                        searchInput.forceActiveFocus();
                    }
                    Keys.onReturnPressed: {
                        window.launchCurrentApp();
                    }

                    delegate: Item {
                        id: appDelegate

                        required property var modelData
                        required property int index

                        function runApp() {
                            if (!modelData.runInTerminal)
                                modelData.execute();
                            else
                                Quickshell.execDetached({
                                "command": ["kitty", "sh", "-c", modelData.execString],
                                "workingDirectory": modelData.workingDirectory
                            });
                            root.closeWindow();
                        }

                        implicitWidth: appGrid.cellWidth
                        implicitHeight: appGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 8
                            radius: 18
                            color: appDelegate.index === appGrid.currentIndex ? ColorService.colorPalette.accentPrimary : "transparent"

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: Ui.tokens.spacing.md

                                IconImage {
                                    Layout.alignment: Qt.AlignHCenter
                                    source: appDelegate.modelData.icon ? Quickshell.iconPath(appDelegate.modelData.icon) : Quickshell.iconPath("application-default-icon")
                                    smooth: true
                                    implicitSize: 64
                                    scale: appDelegate.index === appGrid.currentIndex ? 1.12 : 1

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.InCubic
                                        }

                                    }

                                }

                                RavenText {
                                    Layout.preferredWidth: 100
                                    text: modelData.name || "Unknown"
                                    horizontalAlignment: Text.AlignHCenter
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: appGrid.currentIndex = appDelegate.index
                                onClicked: appDelegate.runApp()
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

            // Footer shortcuts
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: ColorService.colorPalette.backgroundSecondary_300
                opacity: 0.8
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Ui.tokens.padding.md
                    anchors.rightMargin: Ui.tokens.padding.md
                    spacing: Ui.tokens.spacing.lg

                    Item {
                        Layout.fillWidth: true
                    }

                    RavenText {
                        text: "↑↓←→ Navigate"
                        font.pixelSize: 10
                    }

                    RavenText {
                        text: "↵ Launch"
                        font.pixelSize: 10
                    }

                    RavenText {
                        text: "Esc Close"
                        font.pixelSize: 10
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RavenText {
                        text: appGrid.count + (appGrid.count === 1 ? " app" : " apps")
                        color: ColorService.colorPalette.accentPrimary
                        font.pixelSize: 10
                    }

                }

            }

        }

    }

}
