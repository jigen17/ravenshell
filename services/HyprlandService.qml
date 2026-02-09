pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root
    
    readonly property int visibleCount: 9
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
        const result = [];
        
        // Generate fixed workspaces 1-9
        for (let i = 1; i <= visibleCount; i++) {
            const appInfo = getPrimaryAppForWorkspace(i);
            const isOccupied = appInfo.app !== "";
            const isFocused = (i === activeWsId);
            
            result.push({
                id: i,
                workspaceId: i,
                app: appInfo.app,           // Single app string
                isUrgent: appInfo.isUrgent, // Whether this app is urgent
                isOccupied: isOccupied,
                isFocused: isFocused,
                state: isFocused ? "focused" : (isOccupied ? "occupied" : "unoccupied")
            });
        }
        
        visibleWorkspaces = result;
    }
    
    function getPrimaryAppForWorkspace(wsId) {
        let urgentApp = "";
        let focusedApp = "";
        let firstApp = "";
        
        for (const tl of Hyprland.toplevels.values) {
            if (tl.workspace?.id === wsId) {
                const appId = tl.wayland.appId || tl.wayland.title;
                if (appId) {
                    const normalizedAppId = appId;
                    
                    // Priority 1: Urgent windows (highest priority)
                    if (tl.urgent && !urgentApp) {
                        urgentApp = normalizedAppId;
                        // Don't break - keep looking in case there's a focused urgent window
                    }
                    
                    // Priority 2: Focused window
                    if (tl === Hyprland.focusedToplevel) {
                        focusedApp = normalizedAppId;
                    }
                    
                    // Priority 3: First app found (fallback)
                    if (!firstApp) {
                        firstApp = normalizedAppId;
                    }
                }
            }
        }
        
        // Return the highest priority app found
        const selectedApp = urgentApp || focusedApp || firstApp;
        
        return {
            app: selectedApp,
            isUrgent: urgentApp !== "" && selectedApp === urgentApp
        };
    }
}
