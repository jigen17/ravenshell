import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.assets
import qs.config
import qs.services
import qs.widgets

Rectangle {
    id: root

    color: ColorService.colorPalette.backgroundSecondary_300
    radius: 14

    RowLayout {
        anchors.fill: parent
        anchors.margins: Ui.tokens.spacing.sm

        ButtonIcon {
            iconName: Icons.media.images
            buttonPadding: Ui.tokens.spacing.sm
            onClicked: Quickshell.execDetached(["qs", "ipc","-p","ravenshell","call","wallpaperPicker","open"])
        }

        Item {
            Layout.fillWidth: true
        }

        ButtonIcon {
            iconName: Icons.devices.camera
            buttonPadding: Ui.tokens.spacing.sm
        }

        Item {
            Layout.fillWidth: true
        }

        ButtonIcon {
            iconName: Icons.devices.video_camera
            buttonPadding: Ui.tokens.spacing.sm
        }

        Item {
            Layout.fillWidth: true
        }

        ButtonIcon {
            iconName: Icons.utilities.colorPicker
            buttonPadding: Ui.tokens.spacing.sm
        }

        Item {
            Layout.fillWidth: true
        }

        ButtonIcon {
            iconName: Icons.office.clipboard
            buttonPadding: Ui.tokens.spacing.sm
        }

    }

}
