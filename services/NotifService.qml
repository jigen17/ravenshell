pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int maxVisiblePopups: 5
    readonly property int maxHistorySize: 100
    property list<NotifWrapper> history: []
    property list<NotifWrapper> popupQueue: []
    property list<NotifWrapper> visiblePopups: []
    property bool dndEnabled: false
    function receiveNotification(notif) {
        const obj = notifComponent.createObject(root, {
            "notif": notif,
            "notifId": notif.id,
            "appName": notif.appName || "...",
            "appIcon": notif.appIcon,
            "image": notif.image || "...",
            "summary": notif.summary || "...",
            "body": notif.body || "...",
            "urgency": notif.urgency || 0,
            "hasActionIcons": notif.hasActionIcons,
            "hasInlineReply": notif.hasInlineReply,
            "inlineReplyPlaceholder": notif.inlineReplyPlaceholder,
            "actions": notif.actions,
            "expireTimeout": Math.max(notif.expireTimeout, 10000)
        });
        console.log("Icon of the object...:", obj.expireTimeout);
        if (!obj) {
            console.error("Failed to create notification object");
            return;
        }
        // Add to history with size limit
        history = [...history, obj];
        if (history.length > maxHistorySize) {
            const old = history[0];
            old.destroy();
            history = history.slice(1);
        }
        // Add to queue
        popupQueue = [...popupQueue, obj];
        // Try to display
        processQueue();
    }

    function resolveAppIcon(providedIcon, appName) {
        // If icon is provided, use it
        if (providedIcon && providedIcon.length > 0)
            return providedIcon;

        // Try to look up via DesktopEntries
        try {
            const entry = DesktopEntries.heuristicLookup(appName.toLowerCase());
            if (entry && entry.icon)
                return entry.icon;
        } catch (e) {
            console.debug("Could not lookup icon for " + appName + ":", e);
        }
        // Fallback to first letter
        return "";
    }

    function processQueue() {
        const slots = maxVisiblePopups - visiblePopups.length;
        if (slots <= 0 || popupQueue.length === 0)
            return;

        const toShow = popupQueue.slice(0, slots);   // grab what we can show
        const remaining = popupQueue.slice(slots);    // everything left behind

        // commit both lists in one go — no mid-loop QML list mutation
        popupQueue = remaining;
        visiblePopups = [...toShow.reverse(), ...visiblePopups];

        toShow.forEach(n => n.startTimer());
    }

    // Timer expired → only remove from visible, keep in history
    function expirePopup(obj) {
        visiblePopups = visiblePopups.filter(popup => popup !== obj);
        if (obj.timer.running)
            obj.timer.stop();
        processQueue();
    }

    // User dismissed → remov  e from visible AND history, then destroy
    function dismissNotification(obj) {
        visiblePopups = visiblePopups.filter(popup => popup !== obj);
        history = history.filter(item => item !== obj);
        if (obj.timer.running)
            obj.timer.stop();
        obj.notif.expire();  // ← tells the server it's done
        obj.destroy();
        processQueue();
    }

    function clearAllNotifs() {
        for (let item of history) {
            visiblePopups = visiblePopups.filter(p => p !== item);
            if (item.timer.running)
                item.timer.stop();
            item.notif.expire();  // ← same here
            item.destroy();
        }
        history = [];
        popupQueue = [];
        processQueue();
    }
    // --- Notification Object Component ---
    Component {
        id: notifComponent
        NotifWrapper {}
    }

    component NotifWrapper: QtObject {
        id: notifObject
        required property Notification notif
        property int notifId
        property string appName
        property string appIcon
        property string image
        property string summary
        property string body
        property int urgency
        property bool hasActionIcons
        property bool hasInlineReply
        property string inlineReplyPlaceholder
        property var actions
        property int expireTimeout
        property int timeLeft: -1
        property real startTime
        readonly property Timer timer: Timer {
            onTriggered: root.expirePopup(notifObject)
        }

        function startTimer() {
            if (urgency === NotificationUrgency.Critical)
                return;

            const duration = timeLeft > 0 ? timeLeft : expireTimeout;
            timer.interval = Math.max(duration, 1000);
            startTime = Date.now();
            timer.start();
        }

        function pauseTimer() {
            if (timer.running) {
                timeLeft = timer.interval - (Date.now() - startTime);
                timer.stop();
            }
        }

        function resumeTimer() {
            if (timeLeft > 0 && urgency !== NotificationUrgency.Critical) {
                timer.interval = Math.max(timeLeft, 100);
                startTime = Date.now();
                timer.start();
            }
        }
        function invokeAction(actionId) {
            console.log(notifObject.actions[actionId].text);
            notifObject.actions[actionId].invoke;
        }
        function sendInlineReply(text) {
            if (!(notif && hasInlineReply)) {
                console.warn("sendInlineReply: no rawNotif reference");
                return;
            }
            if (!text || text.trim().length === 0) {
                console.warn("sendInlineReply: empty text");
                return;
            }
            rawNotif.sendInlineReply(text);
            root.expirePopup(notifObject);            // dismiss popup after sending
        }
        //NOTE:Add inline reply for popup notifs
    }
    NotificationServer {
        actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true
        inlineReplySupported: true
        onNotification: notif => {
            notif.tracked = true;
            console.log("has reply?:", notif.hasInlineReply);
            console.log("reply text:", notif.inlineReplyPlaceholder);
            root.receiveNotification(notif);
        }
    }
}
