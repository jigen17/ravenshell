import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.config
import qs.widgets
import qs.assets

StyledPanel {
    id: root
    animationType: 1
    anchorPosition: "top"

    property int currentIndex: 0
    keyboardFocus: true
    property int itemCount: SessionService.model.count
    cornerRadius: 30
    margins: 12
    panelHeight: Ui.tokens.iconSize.sm + Ui.tokens.spacing.md * 2
    panelWidth: 300
    KeyboardShortcut {
        name: "powerMenu"
        onPressed: root.toggleWindow()
    }
    contentItem: RowLayout {
        id: rowLayout
        anchors.fill: parent
        focus: true
        // Keyboard navigation with wrapping
        Keys.onLeftPressed: {
            root.currentIndex = (root.currentIndex - 1 + root.itemCount) % root.itemCount;
        }
        Keys.onRightPressed: {
            root.currentIndex = (root.currentIndex + 1) % root.itemCount;
        }
        Keys.onUpPressed: {
            root.currentIndex = (root.currentIndex - 1 + root.itemCount) % root.itemCount;
        }
        Keys.onDownPressed: {
            root.currentIndex = (root.currentIndex + 1) % root.itemCount;
        }
        Keys.onReturnPressed: activateCurrentItem()
        Keys.onEnterPressed: activateCurrentItem()
        Keys.onEscapePressed: root.toggleWindow()

        function activateCurrentItem() {
            SessionService.model.command[root.currentIndex]();
            root.toggleWindow();
        }
        Repeater {
            model: SessionService.model

            delegate: ButtonIcon {
                id: buttonDelegate
                iconName: model.icon
                iconSize: Ui.tokens.iconSize.sm
                buttonPadding: Ui.tokens.spacing.md
                Layout.alignment: Qt.AlignVCenter  // Center vertically AND horizontally

                // Visual feedback for current selection
                opacity: root.currentIndex === index ? 1.0 : 0.6
                scale: root.currentIndex === index ? 1.1 : 1.0
                backgroundColor: root.currentIndex === index ? ColorService.colorPalette.accentPrimary : "transparent"
                hoverColor: ColorService.colorPalette.accentPrimary
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                    }
                }

                // Mouse interaction
                onClicked: {
                    root.currentIndex = index;
                    SessionService.model.command[model.commandnr]();
                    root.toggleWindow();
                }
            }
        }
    }
}
