pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets
import qs.assets

Item {
    id: root
    required property QsMenuEntry trayItem
    signal newmenu
    signal clicked
    implicitHeight: trayItem.isSeparator ? 2 : 30
    Loader {
        anchors.fill: parent
        sourceComponent: root.trayItem.isSeparator ? separatorItem : contentItem
    }

    Component {
        id: separatorItem
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            implicitHeight: 2
            color: ColorService.colorPalette.textPrimary
            opacity: 0.15
        }
    }

    Component {
        id: contentItem
        Item {
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: mouseArea.containsMouse ? ColorService.colorPalette.accentSecondary : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutSine
                    }
                }
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 8
                    rightMargin: 8
                }
                spacing: 8

                RavenCheckBox {
                    implicitWidth: 18
                    implicitHeight: 18
                    visible: root.trayItem.buttonType === QsMenuButtonType.CheckBox
                    checked: root.trayItem.checkState === Qt.Checked
                    Layout.alignment: Qt.AlignVCenter
                }

                IconImage {
                    visible: root.trayItem.icon !== ""
                    source: root.trayItem.icon
                    implicitSize: 24
                    Layout.alignment: Qt.AlignVCenter
                }

                RavenText {
                    text: root.trayItem.text
                    font.pixelSize: 13
                    color: root.trayItem.enabled ? ColorService.colorPalette.textPrimary : ColorService.colorPalette.textSecondary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.width - 10
                }

                ButtonIcon {
                    visible: root.trayItem.hasChildren
                    iconName: Icons.carets.right
                    iconSize: 10
                    opacity: 0.5
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.trayItem.enabled
                onClicked: {
                    if (!root.trayItem.hasChildren) {
                      root.clicked()
                    }
                    else {
                      root.newmenu();
                    }
                   root.trayItem.triggered();
                }
            }
        }
    }
}
