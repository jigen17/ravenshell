import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
  id: root
  Rectangle {
    anchors.centerIn: parent
    color: ColorService.colorPalette.backgroundSecondary_300
    radius: 18
  }
    RowLayout {
        anchors.centerIn: parent
        spacing: Ui.tokens.spacing.md
        ButtonIcon {
            iconName: Icons.media.images
            onClicked: Quickshell.execDetached(["qs", "ipc","-p","ravenshell","call","wallpaperPicker","open"])
        }
        ButtonIcon {
            iconName: Icons.devices.camera
        }
        ButtonIcon {
            iconName: Icons.devices.video_camera
        }
        ButtonIcon {
            iconName: Icons.utilities.colorPicker
        }
        ButtonIcon {
            iconName: Icons.office.clipboard
        }

    }

}
