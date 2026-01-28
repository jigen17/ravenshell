import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets
import qs.assets

Item {
    id: root
    implicitWidth: contentColumn.implicitWidth * 1.4
    implicitHeight: contentColumn.implicitHeight * 1.2
    RowLayout {
        id: contentColumn
        anchors.centerIn: parent
        spacing: 8
        
        // CPU Monitor
        CircularProgress {
            id: cpuProgress
            Layout.alignment: Qt.AlignHCenter
            progress: ResourceService.cpuUsage
            iconName: Icons.system.cpu
        }
        
        // Memory Monitor
        CircularProgress {
            id: memProgress
            Layout.alignment: Qt.AlignHCenter
            progress: ResourceService.memUsage
            iconName: Icons.system.ram
        }
        
        // Temperature Monitor
        CircularProgress {
            id: tempProgress
            Layout.alignment: Qt.AlignHCenter
            progress: ResourceService.temperature
            iconName: Icons.system.temperature
        }
    }
}
