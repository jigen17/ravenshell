//@ pragma UseQApplication
//@ pragma ShellId raven
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QSG_ATLAS_HEIGHT=2048
//@pragma  Env QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor
//@pragma  Env QT_ENABLE_HIGHDPI_SCALING=1
//@ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QSG_RHI_PREFER_SOFTWARE_RENDERER=1
//@ pragma Env QT_MEDIA_BACKEND=ffmpeg
//@ pragma Env QT_FFMPEG_DECODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_FFMPEG_ENCODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_QPA_NO_TABLET_EVENTS=1
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma IconTheme Reversal
import QtQuick
import Quickshell
import qs.modules.Anime
import qs.modules.AppLauncher
import qs.modules.Bar
import qs.modules.ControlCenter
import qs.modules.Lockscreen
import qs.modules.Notifications
import qs.modules.OSD
import qs.modules.Polkit
import qs.modules.PowerMenu
import qs.modules.Wallpaper
import qs.modules.Weather
import qs.services

ShellRoot {
    Bar {
    }

    Wallpaper {
    }

    WallpaperPicker {
    }

    AppLauncher {
    }

    PolkitPopup {
    }

    PowerMenu {
    }

    OSD {
    }

    ControlCenter {
    }

    Lock {
    }

    Weather {
    }

    Anime {
    }

    IdleService {
    }

    NotifManager {
    }

}
