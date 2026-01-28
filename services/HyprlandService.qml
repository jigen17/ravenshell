pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root
    
    readonly property int visibleCount: 5
    readonly property int activeWsId: Hyprland.focusedWorkspace?.id ?? 1
    property var visibleWorkspaces: []
    
    // Keyboard layout tracking
    property string currentKeyboard: ""
    property string currentLayout: ""
    
    function dispatch(cmd) {
        Hyprland.dispatch(cmd);
    }
    
    function activate(wsId) {
        dispatch("workspace " + wsId);
    }
    
    // Listen to keyboard layout changes
    Connections {
        target: Hyprland
        
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const layoutData = event.parse(2);
                root.currentKeyboard = layoutData[0];
                root.currentLayout = layoutData[1];
                
                console.log("Layout changed: ", root.currentLayout);
                
            }
        }
    }
    
    // Rebuild on workspace or window changes
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            rebuild();
        }
    }
    
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            rebuild();
        }
    }
    
    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            rebuild();
        }
    }
    
    Component.onCompleted: {
        rebuild();
    }
    
    function rebuild() {
        // Calculate sliding window: always show 5 consecutive workspaces
        // Position active workspace with 2 above, 2 below (when possible)
        const focused = activeWsId;
        
        // Calculate start position
        // If focused <= 2, start at 1 (shows ws 1-5)
        // Otherwise, center focused with 2 above (shows focused-2 to focused+2)
        const startId = Math.max(1, focused - 2);
        const result = [];
        
        // Generate 5 consecutive workspaces
        for (let i = 0; i < visibleCount; i++) {
            const wsId = startId + i;
            result.push({
                id: wsId,
                workspaceId: wsId,  // Keep both for compatibility
                apps: collectAppsForWorkspace(wsId),
                isOccupied: isWorkspaceOccupied(wsId)
            });
        }
        
        visibleWorkspaces = result;
    }
    
    function isWorkspaceOccupied(wsId) {
        for (const ws of Hyprland.workspaces.values) {
            if (ws.id === wsId) {
                return true;
            }
        }
        return false;
    }
    
    function collectAppsForWorkspace(wsId) {
        const set = new Set();
        for (const tl of Hyprland.toplevels.values) {
            if (tl.workspace?.id === wsId) {
                const appId = tl.wayland.appId || tl.wayland.class;
                if (appId) {
                    set.add(appId.toLowerCase());
                }
            }
        }
        return Array.from(set);
    }
}