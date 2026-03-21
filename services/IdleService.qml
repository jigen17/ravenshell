import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.config
Scope {
  IdleMonitor {
    enabled: !GlobalStatesService.keepAwake
    timeout: 300


    onIsIdleChanged: {
      if (isIdle) {
        Quickshell.execDetached(["qs","ipc","-p","ravenshell","call","lockScreen","lock"])
      }
    }
  }
}
