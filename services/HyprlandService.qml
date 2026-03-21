pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root
    
    readonly property int visibleCount: 9
    readonly property int activeWsId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property string focusedMonitorName: Hyprland.focusedMonitor?.name ?? ""
    
    // Map of monitor names to their workspace arrays
    property var workspacesByMonitor: ({})
    property var topLevels: Hyprland.toplevels.values
    
    // Keyboard layout tracking
    property string currentKeyboard: ""
    property string currentLayout: ""
    
    function dispatch(cmd) {
        Hyprland.dispatch(cmd);
    }
    
    function activate(wsId, monitorName) {
        // Use workspace with monitor parameter to switch on specific monitor
        if (monitorName) {
            // This focuses the monitor and moves the workspace to it
            dispatch("moveworkspacetomonitor " + wsId + " " + monitorName);
            dispatch("workspace " + wsId);
        } else {
            dispatch("workspace " + wsId);
        }
    }
    
    // Get workspaces for a specific monitor
    function getMonitorWorkspaces(monitorName) {
        return workspacesByMonitor[monitorName] || [];
    }
    
    // Get all monitors
    function getMonitors() {
        return Object.keys(workspacesByMonitor);
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
        target: Hyprland.monitors
        function onValuesChanged() {
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
        const newWorkspacesByMonitor = {};
        
        // Initialize each monitor with workspaces 1-9
        for (const monitor of Hyprland.monitors.values) {
            const monitorWorkspaces = [];
            
            for (let i = 1; i <= visibleCount; i++) {
                const appInfo = getPrimaryAppForWorkspace(i, monitor.name);
                const isOccupied = appInfo.app !== "";
                const isFocused = (i === activeWsId);
                
                monitorWorkspaces.push({
                    id: i,
                    workspaceId: i,
                    monitorName: monitor.name,
                    app: appInfo.app,
                    isUrgent: appInfo.isUrgent,
                    isOccupied: isOccupied,
                    isFocused: isFocused,
                    state: isFocused ? "focused" : (isOccupied ? "occupied" : "unoccupied")
                });
            }
            
            newWorkspacesByMonitor[monitor.name] = monitorWorkspaces;
        }
        
        workspacesByMonitor = newWorkspacesByMonitor;
    }
    
    function getPrimaryAppForWorkspace(wsId, monitorName) {
        let urgentApp = "";
        let focusedApp = "";
        let firstApp = "";
        
        for (const tl of Hyprland.toplevels.values) {
            if (tl.workspace?.id === wsId && tl.monitor?.name === monitorName) {
                const appId = tl.wayland.appId || tl.wayland.title;
                if (appId) {
                    const normalizedAppId = appId;
                    
                    // Priority 1: Urgent windows
                    if (tl.urgent && !urgentApp) {
                        urgentApp = normalizedAppId;
                    }
                    
                    // Priority 2: Focused window
                    if (tl === Hyprland.focusedToplevel) {
                        focusedApp = normalizedAppId;
                    }
                    
                    // Priority 3: First app found
                    if (!firstApp) {
                        firstApp = normalizedAppId;
                    }
                }
            }
        }
        
        const selectedApp = urgentApp || focusedApp || firstApp;
        
        return {
            app: selectedApp,
            isUrgent: urgentApp !== "" && selectedApp === urgentApp
        };
    }
}
