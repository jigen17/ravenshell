pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── CPU ──────────────────────────────────────────────────────────
    property double cpuUsage: 0

    // ── Memory ───────────────────────────────────────────────────────
    property double memUsage: 0
    property double memTotal: 0
    property double memFree: 0
    property double memUsed: 0

    // ── GPU ──────────────────────────────────────────────────────────
    property double gpuUsage: 0   // 0.0 - 1.0 from Render/3D busy %

    // ── Temperature ──────────────────────────────────────────────────
    property double temperature: 0

    // ── Disk usage ───────────────────────────────────────────────────
    property double nvmeUsage: 0
    property double sdaUsage: 0

    // ── Constants ────────────────────────────────────────────────────
    readonly property int updateInterval: 10000

    // ── Private ──────────────────────────────────────────────────────
    property var _cpuPrev: ({
            idle: 0,
            total: 0
        })
    property string _gpuBuffer: ""

    // ── Regex ────────────────────────────────────────────────────────
    readonly property var cpuRegex: /^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/m
    readonly property var memTotalRegex: /MemTotal:\s+(\d+)/
    readonly property var memAvailRegex: /MemAvailable:\s+(\d+)/
    readonly property string upSpeed: _fmt(_prevTx, _totalTx)
    readonly property string downSpeed: _fmt(_prevRx, _totalRx)

    property real _totalRx: 0
    property real _totalTx: 0
    property real _prevRx: 0
    property real _prevTx: 0
    property real _prevTime: 0

    function _fmt(prev, curr) {
        var b = Math.max(0, (curr - prev) / Math.max(1, (Date.now() - _prevTime) / 1000));
        if (b < 1024)
            return b.toFixed(0) + " B/s";
        if (b < 1048576)
            return (b / 1024).toFixed(1) + " KB/s";
        return (b / 1048576).toFixed(2) + " MB/s";
    }

    // ── /proc/stat ───────────────────────────────────────────────────
    FileView {
        id: cpuInfo
        path: "/proc/stat"

        onLoaded: {
            const data = cpuInfo.text();
            if (!data)
                return;
            const m = data.match(root.cpuRegex);
            if (!m)
                return;
            const idle = Number(m[4]) + Number(m[5]);
            const total = Number(m[1]) + Number(m[2]) + Number(m[3]) + idle + Number(m[6]) + Number(m[7]) + Number(m[8]) + Number(m[9]) + Number(m[10]);
            const dIdle = idle - root._cpuPrev.idle;
            const dTotal = total - root._cpuPrev.total;
            root._cpuPrev = {
                idle,
                total
            };
            root.cpuUsage = dTotal > 0 ? Math.max(0, 1 - (dIdle / dTotal)) : 0;
        }
    }

    // ── /proc/meminfo ────────────────────────────────────────────────
    FileView {
        id: memInfo
        path: "/proc/meminfo"

        onLoaded: {
            const text = memInfo.text();
            if (!text)
                return;
            const tMatch = text.match(root.memTotalRegex);
            const aMatch = text.match(root.memAvailRegex);
            if (!tMatch || !aMatch)
                return;
            const total = Number(tMatch[1]);
            const free = Number(aMatch[1]);
            root.memTotal = total;
            root.memFree = free;
            root.memUsed = total - free;
            root.memUsage = total > 0 ? (total - free) / total : 0;
        }
    }

    // ── Temperature ──────────────────────────────────────────────────
    FileView {
        id: tempInfo
        path: "/sys/class/thermal/thermal_zone0/temp"
        onLoaded: {
            const raw = Number(tempInfo.text().trim());
            root.temperature = !isNaN(raw) ? raw / 1000.0 : 0;
        }
    }

    // ── GPU — intel_gpu_top JSON ──────────────────────────────────────
    Process {
        id: gpuProcess
        // -J = JSON, -s 2000 = 2s sample, -n 1 = single snapshot then exit
        command: ["intel_gpu_top", "-J", "-s", "2000", "-n", "1"]

        stdout: SplitParser {
            onRead: line => {
                root._gpuBuffer += line + "\n";
            }
        }

        onRunningChanged: {
            if (!running && root._gpuBuffer !== "") {
                try {
                    // Strip the wrapping [ ] that intel_gpu_top adds
                    const clean = root._gpuBuffer.trim().replace(/^\[/, "").replace(/\]$/, "").trim();
                    const json = JSON.parse(clean);
                    const busy = json?.engines?.["Render/3D"]?.busy ?? 0;
                    root.gpuUsage = Math.min(1, Math.max(0, busy / 100));
                } catch (e) {
                    console.warn("intel_gpu_top parse error:", e);
                }
                root._gpuBuffer = "";
            }
        }
    }

    FileView {
        id: netDev
        path: "/proc/net/dev"
        watchChanges: false

        onLoaded: {
            var totalRx = 0, totalTx = 0;
            var lines = netDev.text().split("\n");

            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (!line || line.startsWith("Inter") || line.startsWith("face") || line.startsWith("lo:"))
                    continue;
                var parts = line.replace(/\s+/g, " ").split(" ");
                var rx = parseInt(parts[1]) || 0;
                var tx = parseInt(parts[9]) || 0;
                if (rx === 0 && tx === 0)
                    continue;
                totalRx += rx;
                totalTx += tx;
            }

            root._prevRx = root._totalRx;
            root._prevTx = root._totalTx;
            root._prevTime = Date.now();
            root._totalRx = totalRx;
            root._totalTx = totalTx;
        }
    }
    // ── Disk usage ───────────────────────────────────────────────────
    Process {
        id: dfProcess
        command: ["df", "--output=source,pcent"]

        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/^(\S+)\s+(\d+)%/);
                if (!m)
                    return;
                const pct = Number(m[2]) / 100;
                if (m[1].includes("nvme0n1p"))
                    root.nvmeUsage = pct;
                else if (m[1] === "/dev/sda1")
                    root.sdaUsage = pct;
            }
        }
    }

    // ── Fast poll — every 2s ─────────────────────────────────────────
    Timer {
        interval: root.updateInterval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            cpuInfo.reload();
            memInfo.reload();
            tempInfo.reload();
            netDev.reload();
            gpuProcess.running = true;
        }
    }

    Component.onCompleted: {
        dfProcess.running = true;
    }
}
