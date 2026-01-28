import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.services
import qs.config
import qs.widgets

Rectangle {
    id: root
    implicitWidth: 180
    implicitHeight: 40
    color: ColorService.colorPalette.backgroundSecondary_300
    radius: 18

    WheelHandler {
        target: root
        cursorShape: Qt.PointingHandCursor
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: event => {
            if (event.angleDelta.y < 0)
                HyprlandService.dispatch(`workspace e+1`);
            else if (event.angleDelta.y > 0)
                HyprlandService.dispatch(`workspace e-1`);
        }
    }

    ListView {
        id: workspaceList
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        height: 28
        width: Math.min(contentHeight, parent.height - 16)
        spacing: 4
        interactive: false
        model: HyprlandService.visibleWorkspaces
        clip: true
        orientation: ListView.Horizontal
        delegate: Rectangle {
            id: workspaceRect
            required property var modelData
            required property int index

            width: ListView.view.width
            height: modelData.apps.length > 0 ? appColumn.implicitHeight + 8 : 28
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

            color: modelData.id === HyprlandService.activeWsId ? 
                   ColorService.colorPalette.accentPrimary : "transparent"
            radius: width / 4

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Behavior on height {
                NumberAnimation { 
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }

            // Workspace number indicator
            Text {
                anchors.centerIn: parent
                text: workspaceRect.modelData.id
                color: ColorService.colorPalette.textPrimary
                font.pixelSize: 10
                font.bold: true
                visible: !workspaceRect.modelData.isOccupied || 
                         workspaceRect.modelData.id === HyprlandService.activeWsId
                z: 99
            }

            // App icons
            Column {
                id: appColumn
                anchors.centerIn: parent
                spacing: 4
                visible: modelData.apps.length > 0

                Repeater {
                    model: workspaceRect.modelData.apps.slice(0, 3)

                    delegate: IconImage {
                        required property string modelData
                        property var entry: DesktopEntries.heuristicLookup(modelData)

                        source: entry?.icon ? 
                               Quickshell.iconPath(entry.icon) : 
                               Quickshell.iconPath("image-missing")
                        implicitSize: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        smooth: true
                        antialiasing: true
                    }
                }
            }

            // Click to switch workspace
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered: parent.opacity = 0.8
                onExited: parent.opacity = 1.0
                onClicked: HyprlandService.activate(workspaceRect.modelData.id)
            }

            Behavior on opacity {
                NumberAnimation { 
                    duration: 100
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
