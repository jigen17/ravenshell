import QtQuick
pragma Singleton

QtObject {
    // Icon font
    readonly property string font: "Phosphor-Bold"
    // ============================================
    // NAVIGATION & OVERVIEW
    // ============================================
    readonly property string overview: ""
    // ============================================
    // LAYOUTS
    // ============================================
    readonly property QtObject
    layouts: QtObject {
        readonly property string layout: "\u{e6d6}"
        readonly property string dwindle: ""
        readonly property string master: ""
        readonly property string scrolling: ""
        readonly property string grid_dots: "" //u\{e1fc}"
        readonly property string grid_squares: "" //"u\{e464}"
    }
    // ============================================
    //  ACTION ICONS
    // ===========================================
     readonly property QtObject
     actions: QtObject {
       readonly property string trash: "\u{e4a6}"
       readonly property string trash_simple : "\u{e4a8}"
     }
    // ============================================
    // POWER MENU
    // ============================================
    readonly property QtObject
    power: QtObject {
        readonly property string lock: ""
        readonly property string suspend: ""
        readonly property string logout: ""
        readonly property string reboot: ""
        readonly property string shutdown: ""
    }

    // ============================================
    // CARETS & ARROWS
    // ============================================
    readonly property QtObject
    carets: QtObject {
        readonly property string left: "\u{e158}"
        readonly property string right: "\u{e13a}"
        readonly property string up: "\u{e13c}"
        readonly property string down: "\u{e136}"
        readonly property string doubleLeft: ""
        readonly property string doubleRight: ""
        readonly property string doubleUp: ""
        readonly property string doubleDown: ""
        readonly property string lineLeft: ""
        readonly property string lineRight: ""
        readonly property string lineUp: ""
        readonly property string lineDown: ""
    }

    readonly property QtObject
    arrows: QtObject {
        readonly property string up: ""
        readonly property string down: ""
        readonly property string left: ""
        readonly property string right: ""
        readonly property string counterClockwise: ""
        readonly property string fatLinesDown: ""
        readonly property string out: ""
        readonly property string outCardinal: ""
        readonly property string bendDownLeft: "\u{e018}"
    }

    // ============================================
    // office
    // ============================================
    readonly property QtObject
    office: QtObject {
        readonly property string clipboard: "\u{e196}"
        readonly property string notepad: "\u{e63e}"
    }

    // ============================================
    // SYSTEM MONITORING
    // ============================================
    readonly property QtObject
    system: QtObject {
        readonly property string heartbeat: ""
        readonly property string cpu: ""
        readonly property string gpu: ""
        readonly property string ram: ""
        readonly property string disk: ""
        readonly property string ssd: ""
        readonly property string hdd: ""
        readonly property string temperature: ""
        readonly property string circuitry: ""
        readonly property string robot: ""
    }

    // ============================================
    // NETWORK
    // ============================================
    readonly property QtObject
    network: QtObject {
        readonly property QtObject
        wifi: QtObject {
            readonly property string off: "\u{e4f2}"
            readonly property string none: "\u{e4f0}"
            readonly property string low: "\u{e4ec}"
            readonly property string medium: "\u{e4ee}"
            readonly property string high: "\u{e4ea}"
            readonly property string x: "\u{e4f4}"
        }

        readonly property string ethernet: "\u{edde}"
        readonly property string ethernet_off: "\u{eddc}"
        readonly property string ethernet_x: "\u{edde}"
        readonly property string router: ""
        readonly property string signalNone: ""
        readonly property string vpn: ""
        readonly property string globe: ""
    }

    // ============================================
    // BLUETOOTH
    // ============================================
    readonly property QtObject
    bluetooth: QtObject {
        readonly property string enabled: "\u{e0da}"
        readonly property string connected: "\u{e0dc}"
        readonly property string off: "\u{e0de}"
        readonly property string x: "\u{e0e0}"
    }

    // ============================================
    // TOGGLES
    // ============================================
    readonly property QtObject
    toggles: QtObject {
      readonly property string moon: "\u{e330}"
              readonly property string moonstars: "\u{e58e}"
        readonly property string caffeine: "\u{e1c2}"
        readonly property string gameMode: ""
        readonly property string visibility_on: "\u{e220}"
        readonly property string visibility_off: "\u{e222}"
    }

    // ============================================
    // TOOLBOX
    // ============================================
    readonly property QtObject
    utilities: QtObject {
      readonly property string toolbox: "\u{eca0}"
      readonly property string colorPicker: "\u{e568}"
        readonly property QtObject
        screenshot: QtObject {
            readonly property string region: ""
            readonly property string window: ""
            readonly property string full: ""
            readonly property string screenshots: ""
        }

        readonly property QtObject
        recording: QtObject {
            readonly property string record: ""
            readonly property string recordings: ""
        }

    }

    // ============================================
    // NOTIFICATIONS
    // ============================================
    readonly property QtObject
    notifications: QtObject {
        readonly property string bell: ""
        readonly property string bellRinging: ""
        readonly property string bellSlash: ""
        readonly property string bellZ: ""
    }

    // ============================================
    // MEDIA PLAYER
    // ============================================
    readonly property QtObject
    player: QtObject {
        readonly property string play: "\u{e3d0}"
        readonly property string pause: "\u{e39e}"
        readonly property string stop: "\u{e46c}"
        readonly property string previous: "\u{e5a4}"
        readonly property string rewind: "\u{e6a8}"
        readonly property string forward: "\u{e6a6}"
        readonly property string next: "\u{e5a6}"
        readonly property string shuffle: "\u{e422}"
        readonly property string repeat: "\u{e3f6}"
        readonly property string repeatOnce: "\u{e3f8}"
        readonly property string player: ""
        readonly property QtObject
        apps: QtObject {
            readonly property string spotify: "<font face='Symbols Nerd Font Mono'>󰓇</font>"
            readonly property string firefox: "<font face='Symbols Nerd Font Mono'>󰈹</font>"
            readonly property string chromium: "<font face='Symbols Nerd Font Mono'></font>"
            readonly property string telegram: "<font face='Symbols Nerd Font Mono'></font>"
        }

    }

    // ============================================
    // TIME & CLOCK
    // ============================================
    readonly property QtObject
    time: QtObject {
        readonly property string clock: ""
        readonly property string alarm: ""
        readonly property string timer: ""
        readonly property string countdown: ""
    }

    // ============================================
    // AUDIO
    // =========================.===================
    readonly property QtObject
    audio: QtObject {
        readonly property QtObject
        speaker: QtObject {
            readonly property string slash: "\u{e456}"
            readonly property string x: "\u{e458}"
            readonly property string none: "\u{e454}"
            readonly property string low: "\u{e452}"
            readonly property string high: "\u{e450}"
        }

        readonly property QtObject
        mic: QtObject {
            readonly property string mic: "\u{e326}"
            readonly property string slash: "\u{e328}"
        }

        readonly property string waveform: ""
    }
    // ============================================

    // AUDIO
    // ============================================
    readonly property QtObject
    brightness: QtObject {
        readonly property string high: "\u{e472}"
        readonly property string low: "\u{e474}"
    }
    // ============================================

    // BATTERY
    // ============================================
    readonly property QtObject
    battery: QtObject {
        readonly property string lighting: "\u{e2de}"
        readonly property string plug: ""
        readonly property string full: ""
        readonly property string high: ""
        readonly property string medium: ""
        readonly property string low: ""
        readonly property string empty: ""
        readonly property string charging: ""
    }

    // ============================================
    // POWER PROFILES
    // ============================================
    readonly property QtObject
    powerProfile: QtObject {
        readonly property string powerSave: "\u{e2da}"
        readonly property string power: ""
        readonly property string balanced: "\u{e750}"
        readonly property string performance: "\u{e3fe}"
    }

    // ============================================
    // KEYBOARD
    // ============================================
    readonly property QtObject
    keyboard: QtObject {
        readonly property string keyboard: ""
        readonly property string backspace: ""
        readonly property string enter: ""
        readonly property string shift: ""
    }

    // ============================================
    // DEVICES
    // ============================================
    readonly property QtObject
    devices: QtObject {
        readonly property string headphones: "\u{e2a6}"
        readonly property string mouse: ""
        readonly property string phone: "\u{e1e0}"
        readonly property string watch: ""
        readonly property string game_controller: "\u{e26e}"
        readonly property string printer: ""
        readonly property string camera: "\u{e10e}"
        readonly property string video_camera: "\u{e4da}"
        readonly property string speaker: ""
        readonly property string webcam: "\u{e9b2}"
        readonly property string webcamSlash: "\u{ecdc}"
        readonly property string general: "\u{eba4}"
    }
    // ============================================
    // SECURITY
    // ============================================
    readonly property QtObject
    security: QtObject {
        readonly property string shieldCheck: ""
        readonly property string shield: ""
    }

    // ============================================
    // FILES & DOCUMENTS
    // ============================================
    readonly property QtObject
    files: QtObject {
        readonly property string file: ""
        readonly property string note: ""
        readonly property string notepad: ""
        readonly property string folder: ""
    }

    readonly property QtObject
    development: QtObject {
        readonly property string code: "\u{e1bc}"
        readonly property string file_code: "\u{eb2e}"
    }

    readonly property QtObject
    media: QtObject {
        readonly property string image: "\u{e2ca}"
        readonly property string images: "\u{e836}"
        readonly property string film_strip: "\u{e792}"
        readonly property string video: "\u{e740}"
        readonly property string palette: "\u{e6c8}"
    }

    // ============================================
    // INTERNET
    // ============================================
    readonly property QtObject
    internet: QtObject {
        readonly property string browser: "\u{e0f4}"
        readonly property string globe: "\u{e288}"
        readonly property string mail: ""
        readonly property string chat: ""
        readonly property string rss: ""
    }

    readonly property QtObject
    settings: QtObject {
        readonly property string faders: "\u{e228}"
        readonly property string sliders: "\u{e432}"
        readonly property string gear: "\u{e270}"
        readonly property string gearsix: "\u{e272}"
    }

    // ============================================
    // HELP / INFORMATION
    // ============================================
    readonly property QtObject
    help: QtObject {
        readonly property string info: "\u{e2ce}"
        readonly property string question: "\u{e3e8}"
    }

    //=============================================
    // WEATHER
    // ============================================
    
  readonly property QtObject
     weather: QtObject {
      readonly property string drop: "\u{e210}"
      readonly property string umbrella: "\u{e684}"
      readonly property string wind: "\u{e5d2}"

    }
 }
