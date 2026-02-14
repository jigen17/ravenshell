import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Scope {

  IdleMonitor {

    enabled: true
    timeout: 300

    onIsIdleChanged: {
      if (isIdle) {
        Quickshell.execDetached(["qs","ipc","-p","ravenshell","call","lockScreen","lock"])
      }
    }
  }
}
