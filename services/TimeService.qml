pragma Singleton
import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    // Formatted strings
    readonly property string timeString: Qt.formatTime(clock.date, "hh:mm")
    readonly property string hourString: Qt.formatTime(clock.date, "hh")
    readonly property string minuteString: Qt.formatTime(clock.date, "mm")
    readonly property string dateString: Qt.formatDate(clock.date, "dd MMM yyyy")
        readonly property string dateStringLarge: Qt.formatDate(clock.date, "dd MMMM yyyy");
    readonly property string dayofWeek: Qt.formatDate(clock.date, "ddd") // Sunday, Monday, etc.
    readonly property string shortDate: Qt.formatDate(clock.date, "dd")
    readonly property string shortMonth: Qt.formatDate(clock.date, "MMM")
    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}

