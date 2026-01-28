import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.services
import qs.widgets
import qs.config
Item {
    id: root

    implicitWidth: trayColumn.implicitWidth * 1.4
    implicitHeight: trayColumn.implicitHeight * 1.2
    ColumnLayout {
        id: trayColumn
        anchors.centerIn: parent
        spacing: Ui.tokens.spacing.sm
        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItemContainer
                required property var modelData

                implicitWidth: trayIcon.implicitWidth * 1.2
                implicitHeight: implicitWidth
                // Icon
                IconImage {
                    id: trayIcon
                    anchors.centerIn: parent
                    source: trayItemContainer.modelData.id === "steam" ? Quickshell.iconPath("steam") : trayItemContainer.modelData.icon
                    implicitSize: 22
                    antialiasing: true
                    mipmap: true
                    smooth: true
                    scale: {
                        if (mouseArea.pressed)
                            return 0.95;
                        if (mouseArea.containsMouse)
                            return 1.2;
                        return 1.0;
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                      }
                }
                Loader {
                    // Attention indicator
                    active: trayItemContainer.modelData.status === Status.NeedsAttention
                    anchors.top: parent.top
                    anchors.right: parent.right
                    sourceComponent: Rectangle {
                        implicitWidth: 8
                        implicitHeight: 8
                        radius: implicitHeight / 2
                        color: "#ef4444"

                        // Pulsing animation
                        SequentialAnimation on opacity {
                            running: parent.visible
                            loops: Animation.Infinite
                            NumberAnimation {
                                from: 1.0
                                to: 0.3
                                duration: 800
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                from: 0.3
                                to: 1.0
                                duration: 800
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
                // Mouse interaction
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            trayItemContainer.modelData.activate();
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayItemContainer.modelData.secondaryActivate();
                        } else if (mouse.button === Qt.RightButton && trayItemContainer.modelData.hasMenu) {
                            popup.anchorItem = trayItemContainer;
                            popup.menu = trayItemContainer.modelData.menu;
                            popup.toggleWindow();
                        }
                    }

                    onWheel: wheel => {
                        const delta = wheel.angleDelta.y / 120;
                        trayItemContainer.modelData.scroll(delta, false);
                    }
                }
            }
        }
    }
    TrayPopup {
        id: popup
        animationDuration: 250
    }
}
