pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.assets

Singleton {
    id: root

    function logout() {
        Hyprland.dispatch("closewindow all");
        Qt.callLater(() => Hyprland.dispatch("exit"));
    }
    function lock() {
        Quickshell.execDetached(["qs", "ipc", "-p", "raven", "call", "lockscreen", "lock"]);
    }
    function reboot() {
        Hyprland.dispatch("closewindow all");
        Qt.callLater(() => Quickshell.execDetached(["systemctl", "reboot"]));
    }
    function poweroff() {
        Hyprland.dispatch("closewindow all");
        Qt.callLater(() => Quickshell.execDetached(["systemctl", "poweroff"]));
    }
    function suspend() {
        root.lock();
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    ListModel {
        id: powerMenuModel

        property var command: ({
                0: function () {
                    root.lock();
                },
                1: function () {
                    root.suspend();
                },
                2: function () {
                    root.reboot();
                },
                3: function () {
                    root.logout();
                },
                4: function () {
                    root.poweroff();
                }
            })

        ListElement {
            name: "Lock"
            icon: ""  // Will be set in Component.onCompleted
            commandnr: 0
        }
        ListElement {
            name: "Suspend"
            icon: ""
            commandnr: 1
        }
        ListElement {
            name: "Reboot"
            icon: ""
            commandnr: 2
        }
        ListElement {
            name: "Logout"
            icon: ""
            commandnr: 3
        }
        ListElement {
            name: "Shutdown"
            icon: ""
            commandnr: 4
        }

        Component.onCompleted: {
            setProperty(0, "icon", Icons.power.lock);
            setProperty(1, "icon", Icons.power.suspend);
            setProperty(2, "icon", Icons.power.reboot);
            setProperty(3, "icon", Icons.power.logout);
            setProperty(4, "icon", Icons.power.shutdown);
        }
    }

    property alias model: powerMenuModel
}
