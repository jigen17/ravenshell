pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.widgets
import qs.assets
StyledPopup {
    id: root
    property QsMenuHandle menu



    contentItem: StackView {
        id: stackView
        implicitWidth: 240
        implicitHeight: currentItem ? currentItem.implicitHeight : 0

        pushEnter:  Transition { NumberAnimation { duration: 0 } }
        pushExit:   Transition { NumberAnimation { duration: 0 } }
        popEnter:   Transition { NumberAnimation { duration: 0 } }
        popExit:    Transition { NumberAnimation { duration: 0 } }

        initialItem: TrayMenu {
            handle: root.menu
        }

        component TrayMenu: ColumnLayout {
            id: page
            property QsMenuHandle handle
            property bool isSubMenu: false
            spacing: 2

            property bool show: false
            opacity: show ? 1.0 : 0.0
            scale:   show ? 1.0 : 0.95

            Component.onCompleted:    show = true
            StackView.onActivating:   show = true
            StackView.onDeactivating: show = false

            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

            QsMenuOpener {
                id: opener
                menu: page.handle
            }

            // Back button
            Rectangle {
                visible: page.isSubMenu
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 4
                color: backArea.containsMouse
                    ? ColorService.colorPalette.accentSecondary
                    : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    spacing: 6
                    RavenIcon {
                        iconName: Icons.carets.left
                        iconSize: 12
                        opacity: 0.6
                    }
                    RavenText {
                        text: "Back"
                        font.pixelSize: 13
                        color: ColorService.colorPalette.textPrimary
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: stackView.pop()
                }
            }

            Repeater {
                model: opener.children
                delegate: TrayMenuItem {
                    required property QsMenuEntry modelData
                    trayItem: modelData
                    Layout.fillWidth: true
                    onNewmenu: stackView.push(subMenuComp.createObject(null, {
                        handle: modelData,
                        isSubMenu: true
                      }))
                    onClicked: root.closeWindow();
                }
            }
        }

        Component {
            id: subMenuComp
            TrayMenu {}
        }
    }
}
