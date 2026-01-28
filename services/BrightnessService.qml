pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.assets

Singleton {
    id: root
    readonly property int max_brightness: 937
    property int nightLightTemperature: 4000
    property int _rawBrightness: -1
    property real brightness: _rawBrightness / max_brightness
    
    signal brightnessValueChanged()
    
    property bool isUserAdjusting: false
    
    readonly property string brightnessIcon: {
        if (brightness <= 0.5) return Icons.brightness.low
        return Icons.brightness.high
    }
    
    onBrightnessChanged: {
        if (!isUserAdjusting) {
            brightnessValueChanged()
        }
    }
    
    FileView {
        id: brightnessView
        path: "/sys/class/backlight/intel_backlight/actual_brightness"
        watchChanges: true
        printErrors: false
        onFileChanged: {
            brightnessView.reload()
        }
        onLoaded: {
            root._rawBrightness = brightnessView.data()
        }
    }
    
    // Rate-limited commands
    Timer {
        id: rateLimit
        interval: 30
        repeat: false
        property string pending: ""
        onTriggered: {
            if (!pending) return
            Quickshell.execDetached(["brightnessctl", "set", pending])
            pending = ""
        }
    }
    
    Timer {
        id: userAdjustmentTimer
        interval: 500
        repeat: false
        onTriggered: {
            root.isUserAdjusting = false
        }
    }
    
    function setBrightness(value: real) {
        value = Math.max(0.01, Math.min(1.0, value))
        root.isUserAdjusting = true
        userAdjustmentTimer.restart()
        
        rateLimit.pending = Math.round(value * 100) + "%"
        rateLimit.restart()
    }
    
    function wheelAction(event: WheelEvent) {
        const dir = event.angleDelta.y > 0 ? 1 : -1
        const step = 0.01
        const newValue = brightness + (dir * step)
        setBrightness(newValue)
    }
    
    function setNightLight(temp: int) {
        nightLightTemperature = Math.max(1000, Math.min(10000, temp))
        Quickshell.execDetached(["pkill", "-f", "hyprsunset"])
        Quickshell.execDetached(["hyprsunset", "-t", String(nightLightTemperature)])
    }
    
    function disableNightLight() {
        Quickshell.execDetached(["pkill", "-f", "hyprsunset"])
    }
    
    function setPreset(name: string) {
        switch (name) {
        case "low":    setBrightness(0.25); break
        case "medium": setBrightness(0.50); break
        case "high":   setBrightness(0.75); break
        case "max":    setBrightness(1.00); break
        default:
            console.warn("Unknown brightness preset:", name)
        }
    }
    
    Component.onCompleted: {
        console.log("Brightness service initialized (hardcoded intel_backlight)")
    }
}
