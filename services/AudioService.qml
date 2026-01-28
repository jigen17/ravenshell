pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.config
import qs.assets

Singleton {
    id: root

    // Devices
    readonly property PwNode sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property PwNode source: validatedSource
    readonly property bool hasInput: !!source
    readonly property list<PwNode> sinks: deviceNodes.sinks
    readonly property list<PwNode> sources: deviceNodes.sources

    readonly property real epsilon: 0.005

    // Output Volume
    readonly property real volume: {
        if (!sink?.audio)
            return 0;
        const vol = sink.audio.volume;
        if (vol === undefined || isNaN(vol))
            return 0;
        return Math.max(0, Math.min(1.0, vol));
    }
    readonly property bool sinkMuted: sink?.audio?.muted ?? true

    // Input Volume
    readonly property real sourceVolume: {
        if (!source?.audio)
            return 0;
        const vol = source.audio.volume;
        if (vol === undefined || isNaN(vol))
            return 0;
        return Math.max(0, Math.min(1.0, vol));
    }
    readonly property bool sourceMuted: source?.audio?.muted ?? true

    readonly property real stepVolume: 0.1

    //Icons
    readonly property string sinkIcon: {
        if (sinkMuted)
            return Icons.audio.speaker.slash;
        if (volume <= 0.33)
            return Icons.audio.speaker.none;
        if (volume <= 0.66)
            return Icons.audio.speaker.low;
        return Icons.audio.speaker.high;
    }
    readonly property string sourceIcon: {
        if (sourceMuted || sourceVolume <= Number.EPSILON) {
            return Icons.audio.mic.slash;
        }
        return Icons.audio.mic.mic;
    }
    // Filtered device nodes (non-stream sinks and sources)
    readonly property var deviceNodes: Pipewire.ready ? Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink) {
                acc.sinks.push(node);
            } else if (node.audio) {
                acc.sources.push(node);
            }
        }
        return acc;
    }, {
        "sources": [],
        "sinks": []
    }) : {
        "sources": [],
        "sinks": []
    }

    // Validated source (ensures it's a proper audio source, not a sink)
    readonly property PwNode validatedSource: {
        if (!Pipewire.ready) {
            return null;
        }
        const raw = Pipewire.defaultAudioSource;
        if (!raw || raw.isSink || !raw.audio) {
            return null;
        }
        if (raw.type && typeof raw.type === "string" && !raw.type.startsWith("Audio/Source")) {
            return null;
        }
        return raw;
    }

    // Loopback protection flags
    property bool isSettingOutputVolume: false
    property bool isSettingInputVolume: false

    // Bind default sink and source to ensure their properties are available
    PwObjectTracker {
        id: sinkTracker
        objects: root.sink ? [root.sink] : []
    }

    PwObjectTracker {
        id: sourceTracker
        objects: root.source ? [root.source] : []
    }

    // Bind all devices to ensure their properties are available
    PwObjectTracker {
        objects: [...root.sinks, ...root.sources]
    }

    // Watch output device changes for clamping
    Connections {
        target: sink?.audio ?? null

        function onVolumeChanged() {
            if (root.isSettingOutputVolume) {
                return;
            }

            if (!root.sink?.audio) {
                return;
            }

            const vol = root.sink.audio.volume;
            if (vol === undefined || isNaN(vol)) {
                return;
            }

            if (vol > 1.0) {
                root.isSettingOutputVolume = true;
                Qt.callLater(() => {
                    if (root.sink?.audio && root.sink.audio.volume > 1.0) {
                        root.sink.audio.volume = 1.0;
                    }
                    root.isSettingOutputVolume = false;
                });
            }
        }
    }

    // Watch input device changes for clamping
    Connections {
        target: source?.audio ?? null

        function onVolumeChanged() {
            if (root.isSettingInputVolume) {
                return;
            }

            if (!root.source?.audio) {
                return;
            }

            const vol = root.source.audio.volume;
            if (vol === undefined || isNaN(vol)) {
                return;
            }

            if (vol > 1.0) {
                root.isSettingInputVolume = true;
                Qt.callLater(() => {
                    if (root.source?.audio && root.source.audio.volume > 1.0) {
                        root.source.audio.volume = 1.0;
                    }
                    root.isSettingInputVolume = false;
                });
            }
        }
    }

    // Output Control
    function increaseVolume() {
        if (!Pipewire.ready || !sink?.audio) {
            return;
        }
        if (volume >= 1.0) {
            return;
        }
        setVolume(Math.min(1.0, volume + stepVolume));
    }

    function decreaseVolume() {
        if (!Pipewire.ready || !sink?.audio) {
            return;
        }
        if (volume <= 0) {
            return;
        }
        setVolume(Math.max(0, volume - stepVolume));
    }

    function setVolume(newVolume: real) {
        if (!Pipewire.ready || !sink?.ready || !sink?.audio) {
            return;
        }

        const clampedVolume = Math.max(0, Math.min(1.0, newVolume));
        const delta = Math.abs(clampedVolume - sink.audio.volume);
        if (delta < root.epsilon) {
            return;
        }

        isSettingOutputVolume = true;
        sink.audio.muted = false;
        sink.audio.volume = clampedVolume;

        Qt.callLater(() => {
            isSettingOutputVolume = false;
        });
    }

    function setOutputMuted(muted: bool) {
        if (!Pipewire.ready || !sink?.audio) {
            //Logger.w("AudioService", "No sink available or Pipewire not ready");
            return;
        }

        sink.audio.muted = muted;
    }
    function toggleSinkMute() {
        if (!Pipewire.ready || !sink?.audio) {
            return;
        }
        sink.audio.muted = !sink.audio.muted;
    }
    // Input Control
    function increaseInputVolume() {
        if (!Pipewire.ready || !source?.audio) {
            return;
        }
        if (inputVolume >= 1.0) {
            return;
        }
        setInputVolume(Math.min(1.0, inputVolume + stepVolume));
    }

    function decreaseInputVolume() {
        if (!Pipewire.ready || !source?.audio) {
            return;
        }
        setInputVolume(Math.max(0, inputVolume - stepVolume));
    }

    function setInputVolume(newVolume: real) {
        if (!Pipewire.ready || !source?.ready || !source?.audio) {
            //Logger.w("AudioService", "No source available or not ready");
            return;
        }

        const clampedVolume = Math.max(0, Math.min(1.0, newVolume));
        const delta = Math.abs(clampedVolume - source.audio.volume);
        if (delta < root.epsilon) {
            return;
        }

        isSettingInputVolume = true;
        source.audio.muted = false;
        source.audio.volume = clampedVolume;

        Qt.callLater(() => {
            isSettingInputVolume = false;
        });
    }

    function setInputMuted(muted: bool) {
        if (!Pipewire.ready || !source?.audio) {
            //Logger.w("AudioService", "No source available or Pipewire not ready");
            return;
        }

        source.audio.muted = muted;
    }

    function toggleSourceMute() {
        if (!Pipewire.ready || !source?.audio) {
            return;
        }
        source.audio.muted = !source.audio.muted;
    }
    // Device Selection
    function setAudioSink(newSink: PwNode): void {
        if (!Pipewire.ready) {
            //Logger.w("AudioService", "Pipewire not ready");
            return;
        }
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        if (!Pipewire.ready) {
            //Logger.w("AudioService", "Pipewire not ready");
            return;
        }
        Pipewire.preferredDefaultAudioSource = newSource;
    }
}
