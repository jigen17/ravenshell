import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.assets
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    KeyboardShortcut {
        name: "lockScreen"
        onPressed: {
            lockloader.active = !lockloader.active;
            console.log("pressed lock");
        }
    }

    Loader {
        id: lockloader
        active: false
        sourceComponent: PanelWindow {
            exclusionMode: ExclusionMode.Ignore
            visible: true
            anchors {
                top: true
                bottom: true
                right: true
                left: true
            }

            color: ColorService.colorPalette.backgroundSecondary

            ClippingRectangle {
                anchors {
                    fill: parent
                    margins: Ui.tokens.spacing.md
                }
                color: ColorService.colorPalette.backgroundSecondary
                radius: 18
                Image {
                    id: bakckgroundImage
                    anchors.fill: parent
                    source: Settings.config.wallpapers.path
                    smooth: true
                    cache: true
                }
                MultiEffect {
                    anchors.fill: parent
                    source: bakckgroundImage
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 32
                }

                ColumnLayout {
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        bottomMargin: Ui.tokens.spacing.md * 2
                        rightMargin: Ui.tokens.spacing.md * 2
                    }

                    ButtonIcon {
                        iconName: Icons.power.logout
                        buttonPadding: Ui.tokens.spacing.md
                        backgroundColor: ColorService.colorPalette.accentonPrimary
                    }
                    ButtonIcon {
                        iconName: Icons.power.reboot
                        buttonPadding: Ui.tokens.spacing.md
                       backgroundColor: ColorService.colorPalette.accentonPrimary
                    }
                    ButtonIcon {
                        iconName: Icons.power.shutdown
                        buttonPadding: Ui.tokens.spacing.md
                        backgroundColor: ColorService.colorPalette.accentonPrimary
                      }
                }
            }
        }
    }
}
