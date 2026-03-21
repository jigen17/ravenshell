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
    anchorPosition: "top"
    keyboardFocus: true
    // Smaller panel
    panelWidth: 450
    panelHeight: 400
    cornerRadius: 24
    margins: 12

    KeyboardShortcut {
        name: "appLauncher"
        onPressed: root.toggleWindow()
    }

    contentItem: Item {
        id: rootContent

        // Categories
        property var categoryModel: [
            {
                "name": "",
                "icon": Icons.layouts.grid_squares
            },
            {
                "name": "Development",
                "icon": Icons.development.code
            },
            {
                "name": "Game",
                "icon": Icons.devices.game_controller
            },
            {
                "name": "Graphics",
                "icon": Icons.media.palette
            },
            {
                "name": "Network",
                "icon": Icons.internet.globe
            },
            {
                "name": "AudioVideo",
                "icon": Icons.media.film_strip
            },
            {
                "name": "Office",
                "icon": Icons.office.notepad
            },
            {
                "name": "Settings",
                "icon": Icons.settings.gear
            },
            {
                "name": "Utility",
                "icon": Icons.utilities.toolbox
            },
            {
                "name": "System",
                "icon": Icons.help.info
            }
        ]
        property int currentCategoryIndex: 0

        function nextCategory() {
            currentCategoryIndex = (currentCategoryIndex + 1) % categoryModel.length;
            if (currentCategoryIndex === 0)
                AppService.clearCategory();
            else
                AppService.setCategory(categoryModel[currentCategoryIndex].name);
        }

        anchors.fill: parent
        focus: true

        Connections {
            function onOpened() {
                Qt.callLater(() => {
                    return searchField.forceActiveFocus();
                });
            }

            function onClosed() {
                AppService.clearSearch();
            }

            target: root
        }

        RowLayout {
            anchors.fill: parent
            spacing: Ui.tokens.spacing.sm

            // =========================================================
            // Sidebar (Repeater)
            // =========================================================
            Item {
                Layout.preferredWidth: 50
                Layout.fillHeight: true

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: ColorService.colorPalette.accentTertiary
                }

                ColumnLayout {
                    id: categoriesColumn

                    anchors.centerIn: parent
                    spacing: 0

                    Repeater {
                        model: rootContent.categoryModel

                        delegate: ButtonIcon {
                            required property var modelData
                            required property int index

                            iconName: modelData.icon
                            iconSize: Ui.tokens.iconSize.sm
                            buttonPadding: Ui.tokens.spacing.sm
                            opacity: AppService.selectedCategory === modelData.name ? 1 : 0.45
                            enabled: index === rootContent.currentCategoryIndex
                            onClicked: {
                                rootContent.currentCategoryIndex = index;
                                if (modelData.name === "")
                                    AppService.clearCategory();
                                else
                                    AppService.setCategory(modelData.name);
                            }
                        }
                    }
                }
            }

            // =========================================================
            // Main Content
            // =========================================================
            ColumnLayout {
                id: mainContent

                function launchCurrentApp() {
                    if (appList.count > 0 && appList.currentIndex >= 0) {
                        const delegate = appList.itemAtIndex(appList.currentIndex);
                        if (delegate && delegate.runApp)
                            delegate.runApp();
                    }
                }

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: Ui.tokens.spacing.xs
                Layout.bottomMargin: Ui.tokens.spacing.xs
                spacing: Ui.tokens.spacing.sm

                function moveIndex(delta) {
                    if (appList.count === 0)
                        return;
                    appList.currentIndex = (appList.currentIndex + delta + appList.count) % appList.count;
                    appList.positionViewAtIndex(appList.currentIndex, ListView.Contain);
                }

                function setIndex(index) {
                    if (appList.count === 0)
                        return;
                    appList.currentIndex = index;
                    appList.positionViewAtIndex(appList.currentIndex, ListView.Contain);
                }
                // =====================================================
                // Search Field
                // =====================================================
                TextField {
                    id: searchField

                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    padding: Ui.tokens.spacing.sm
                    font.pixelSize: Ui.tokens.fontSize.sm
                    font.family: Settings.config.fonts.primary
                    color: ColorService.colorPalette.textPrimary
                    placeholderText: "Search applications..."
                    placeholderTextColor: Qt.rgba(ColorService.colorPalette.textSecondary.r, ColorService.colorPalette.textSecondary.g, ColorService.colorPalette.textSecondary.b, 0.4)
                    onTextChanged: {
                        AppService.searchApplications(text);
                        if (appList.count > 0)
                            appList.currentIndex = 0;
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.closeWindow();
                            event.accepted = true;
                            return;
                        }
                        if (event.key === Qt.Key_Tab) {
                            rootContent.nextCategory();
                            event.accepted = true;
                            return;
                        }
                        if (appList.count === 0)
                            return;

                        switch (event.key) {
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            mainContent.launchCurrentApp();
                            event.accepted = true;
                            break;
                        case Qt.Key_Down:
                        case Qt.Key_Right:
                            mainContent.moveIndex(1);
                            event.accepted = true;
                            break;
                        case Qt.Key_Up:
                        case Qt.Key_Left:
                            mainContent.moveIndex(-1);
                            event.accepted = true;
                            break;
                        case Qt.Key_PageDown:
                            mainContent.moveIndex(5);
                            event.accepted = true;
                            break;
                        case Qt.Key_PageUp:
                            mainContent.moveIndex(-5);
                            event.accepted = true;
                            break;
                        case Qt.Key_Home:
                            mainContent.setIndex(0);
                            event.accepted = true;
                            break;
                        case Qt.Key_End:
                            mainContent.setIndex(appList.count - 1);
                            event.accepted = true;
                            break;
                        }
                    }
                    background: Rectangle {
                        radius: 10
                        color: ColorService.colorPalette.backgroundSecondary_700
                        border.width: 2
                        border.color: searchField.activeFocus ? ColorService.colorPalette.accentPrimary : Qt.rgba(ColorService.colorPalette.accentPrimary.r, ColorService.colorPalette.accentPrimary.g, ColorService.colorPalette.accentPrimary.b, 0.3)
                    }
                }

                // =====================================================
                // App List
                // =====================================================
                ListView {
                    id: appList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: AppService.searchResults
                    clip: true
                    spacing: Ui.tokens.spacing.xs
                    currentIndex: 0
                    cacheBuffer: 100 // Cache some off-screen items
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: 200

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

                        implicitWidth: appList.width
                        implicitHeight: 50

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: appDelegate.index === appList.currentIndex ? ColorService.colorPalette.accentonSecondary : ColorService.colorPalette.backgroundSecondary_700
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Ui.tokens.spacing.sm
                            spacing: Ui.tokens.spacing.sm

                            IconImage {
                                implicitSize: 26
                                source: {
                                    const path = Quickshell.iconPath(appDelegate.modelData.icon, true);
                                    return path.length > 0 ? path : Quickshell.iconPath("application-default-icon");
                                }
                            }

                            ColumnLayout {
                                spacing: 2

                                RavenText {
                                    text: modelData.name || "Unknown"
                                    font.pixelSize: Ui.tokens.fontSize.sm
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                RavenText {
                                    text: modelData.comment || ""
                                    font.pixelSize: Ui.tokens.fontSize.xs
                                    Layout.maximumWidth: 320
                                    opacity: 0.65
                                    elide: Text.ElideRight
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: appList.currentIndex = appDelegate.index
                            onClicked: appDelegate.runApp()
                        }
                    }
                }
            }
        }
    }
}
