import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    Loader {
        active: NotifService.popupQueue.count > 0

        PanelWindow {
            id: root

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Auto
            color: "transparent"
            implicitWidth: 300
            implicitHeight: column.implicitHeight + 10

            anchors {
                top: true
                right: true
            }

            margins {
                top: 10
                right: 10
            }

            ColumnLayout {
                id: column

                anchors {
                    left: parent.left
                    right: parent.right
                }

                Repeater {
                    model: NotifService.visiblePopups

                    delegate: NotifItem {
                        required property var modelData

                        notifItem: modelData
                        onDismissed: NotifService.dismissNotification(modelData)
                        Layout.fillWidth: true
                        implicitHeight: 140
                    }

                }

            }

        }

    }

}
