pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    // Public properties
    property double cpuUsage: 0
    property double cpuIdle: 0
    property double cpuTotal: 0
    property double memUsage: 0
    property double memTotal: 0
    property double memFree: 0
    property double memUsed: 0
    property double temperature: 0
    
    // Constants
    readonly property int updateInterval: 5000  // 2 seconds (more responsive)
    readonly property double tempDivisor: 100000.0  // Standard thermal_zone divisor
    
    // Cached regex patterns (compiled once)
    readonly property var cpuRegex: /^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/m
    readonly property var memTotalRegex: /MemTotal:\s+(\d+)/
    readonly property var memAvailRegex: /MemAvailable:\s+(\d+)/
    
    FileView {
        id: cpuInfo
        property double lastIdle: 0
        property double lastTotal: 0
        path: "/proc/stat"
        
        onLoaded: {
            const data = cpuInfo.text();
            if (!data) return;
            
            const match = data.match(root.cpuRegex);
            if (!match) return;
            
            // Parse values directly from match groups
            const user = Number(match[1]);
            const nice = Number(match[2]);
            const system = Number(match[3]);
            const idle = Number(match[4]);
            const iowait = Number(match[5]);
            const irq = Number(match[6]);
            const softirq = Number(match[7]);
            const steal = Number(match[8]);
            const guest = Number(match[9]);
            const guestNice = Number(match[10]);
            
            const idleTime = idle + iowait;
            const totalTime = user + nice + system + idleTime + irq + softirq + steal + guest + guestNice;
            
            const deltaIdle = idleTime - lastIdle;
            const deltaTotal = totalTime - lastTotal;
            
            lastIdle = idleTime;
            lastTotal = totalTime;
            
            root.cpuIdle = idleTime;
            root.cpuTotal = totalTime;
            root.cpuUsage = deltaTotal > 0 ? 1 - (deltaIdle / deltaTotal) : 0;
        }
    }
    
    FileView {
        id: memInfo
        path: "/proc/meminfo"
        
        onLoaded: {
            const text = memInfo.text();
            if (!text) return;
            
            const totalMatch = text.match(root.memTotalRegex);
            const availMatch = text.match(root.memAvailRegex);
            
            if (!totalMatch || !availMatch) return;
            
            const total = Number(totalMatch[1]);
            const free = Number(availMatch[1]);
            const used = total - free;
            
            root.memTotal = total;
            root.memFree = free;
            root.memUsed = used;
            root.memUsage = total > 0 ? used / total : 0;
        }
    }
    
    FileView {
        id: tempInfo
        path: "/sys/class/thermal/thermal_zone8/temp"
        
        onLoaded: {
            const text = tempInfo.text().trim();
            if (!text) return;
            
            const raw = Number(text);
            root.temperature = !isNaN(raw) ? raw / root.tempDivisor : 0;
        }
    }
    
    Timer {
        interval: root.updateInterval
        repeat: true
        running: true
        triggeredOnStart: true  // Get initial values immediately
        
        onTriggered: {
            cpuInfo.reload();
            memInfo.reload();
            tempInfo.reload();
        }
    }
}
