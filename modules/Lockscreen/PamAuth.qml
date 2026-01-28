import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
    id: root
    
    // ============ SIGNALS ============
    
    /// Emitted when authentication succeeds
    signal unlocked
    
    /// Emitted when authentication fails
    signal failed(string reason)
    
    /// Emitted when lockout occurs
    signal locked(int duration)
    
    /// Emitted when lockout expires
    signal lockoutExpired
    
    
    // ============ PROPERTIES ============
    
    /// Current password input
    property string currentText: ""
    
    /// Whether PAM is waiting for password input
    property bool waitingForPassword: false
    
    /// Whether unlock attempt is in progress
    property bool unlockInProgress: false
    
    /// Whether to show failure message
    property bool showFailure: false
    
    /// Whether to show info message
    property bool showInfo: false
    
    /// Current error message
    property string errorMessage: ""
    
    /// Current info message
    property string infoMessage: ""
    
    /// Number of failed attempts
    property int attemptCount: 0
    
    /// Maximum attempts before lockout
    property int maxAttempts: 5
    
    /// Whether account is locked
    property bool isLocked: false
    
    /// Remaining lockout time in seconds
    property int lockoutTime: 0
    
    /// PAM config directory
    readonly property string pamConfigDirectory: "/etc/pam.d"
    
    /// PAM config file
    readonly property string pamConfig: "system-auth"
    
    
    // ============ COMPUTED PROPERTIES ============
    
    /// Formatted lockout time (M:SS)
    readonly property string lockoutTimeString: {
        if (lockoutTime <= 0) return "0:00"
        var mins = Math.floor(lockoutTime / 60)
        var secs = lockoutTime % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
    
    /// Current status message
    readonly property string statusMessage: {
        if (isLocked) {
            return "Locked for " + lockoutTimeString
        }
        if (unlockInProgress) {
            return "Authenticating..."
        }
        if (attemptCount > 0) {
            var remaining = maxAttempts - attemptCount
            return remaining + " attempt" + (remaining !== 1 ? "s" : "") + " remaining"
        }
        if (waitingForPassword) {
            return "Enter password"
        }
        return "Ready"
    }
    
    
    // ============ FUNCTIONS ============
    
    /**
     * Attempt to unlock with current password
     */
    function tryUnlock() {
        if (isLocked) {
            console.warn("Cannot unlock: account is locked")
            showError("Account locked. Wait " + lockoutTimeString)
            return
        }
        
        if (unlockInProgress) {
            console.warn("Unlock already in progress")
            return
        }
        
        if (currentText === "") {
            console.warn("Cannot unlock: password is empty")
            showError("Password cannot be empty")
            return
        }
        
        if (waitingForPassword) {
            console.log("Responding to PAM with password")
            pam.respond(currentText)
            unlockInProgress = true
            waitingForPassword = false
            showInfo = false
            return
        }
        
        console.log("Starting PAM authentication")
        unlockInProgress = true
        pam.start()
    }
    
    /**
     * Reset all state
     */
    function reset() {
        currentText = ""
        attemptCount = 0
        isLocked = false
        lockoutTime = 0
        unlockInProgress = false
        waitingForPassword = false
        showFailure = false
        showInfo = false
        errorMessage = ""
        infoMessage = ""
        lockoutTimer.stop()
    }
    
    /**
     * Show error message
     */
    function showError(message) {
        errorMessage = message
        showFailure = true
        showInfo = false
    }
    
    /**
     * Show info message
     */
    function showMessage(message) {
        infoMessage = message
        showInfo = true
        showFailure = false
    }
    
    /**
     * Clear password field
     */
    function clearPassword() {
        currentText = ""
    }
    
    
    // ============ INTERNAL FUNCTIONS ============
    
    function _handleSuccess() {
        console.log("Authentication successful")
        attemptCount = 0
        unlockInProgress = false
        currentText = ""
        showFailure = false
        showInfo = false
        unlocked()
    }
    
    function _handleFailure(reason) {
        console.log("Authentication failed:", reason)
        attemptCount++
        unlockInProgress = false
        currentText = ""
        showError(reason)
        failed(reason)
        
        // Check if we should lock
        if (attemptCount >= maxAttempts) {
            _lockAccount()
        }
    }
    
    function _lockAccount() {
        console.log("Max attempts reached, locking account")
        isLocked = true
        lockoutTime = 60 // 60 seconds lockout
        lockoutTimer.restart()
        showError("Too many attempts. Locked for " + lockoutTime + "s")
        locked(lockoutTime)
    }
    
    
    // ============ PROPERTY WATCHERS ============
    
    onShowInfoChanged: {
        if (showInfo) {
            showFailure = false
        }
    }
    
    onShowFailureChanged: {
        if (showFailure) {
            showInfo = false
        }
    }
    
    onCurrentTextChanged: {
        if (currentText !== "") {
            showInfo = false
            showFailure = false
        }
    }
    
    
    // ============ PAM CONTEXT ============
    
    PamContext {
        id: pam
        configDirectory: root.pamConfigDirectory
        config: root.pamConfig
        
        onPamMessage: function(message, messageIsError, responseRequired) {
            console.log("PAM message:", message, "isError:", messageIsError, "responseRequired:", responseRequired)
            
            if (responseRequired) {
                if (root.currentText !== "") {
                    console.log("Auto-responding to PAM with password")
                    this.respond(root.currentText)
                    root.unlockInProgress = true
                } else {
                    console.log("Waiting for password input")
                    root.waitingForPassword = true
                    root.showMessage("Enter password")
                }
            } else if (messageIsError) {
                root.showError(message)
            } else {
                root.showMessage(message)
            }
        }
        
        onCompleted: function(result) {
            console.log("PAM completed with result:", result)
            
            switch(result) {
                case PamResult.Success:
                    root._handleSuccess()
                    break
                    
                case PamResult.Failed:
                    root._handleFailure("Authentication failed")
                    break
                    
                case PamResult.MaxTries:
                    root._handleFailure("Maximum attempts exceeded")
                    root._lockAccount()
                    break
                    
                case PamResult.Error:
                    root._handleFailure("System error occurred")
                    break
                    
                default:
                    root._handleFailure("Unknown error")
                    break
            }
        }
        
        onError: function(err, message) {
            var errorMsg = message || PamError.toString(err) || "Authentication error"
            console.error("PAM error:", err, "message:", errorMsg)
            root._handleFailure(errorMsg)
        }
    }
    
    
    // ============ TIMERS ============
    
    /// Lockout countdown timer
    Timer {
        id: lockoutTimer
        interval: 1000
        repeat: true
        running: isLocked && lockoutTime > 0
        
        onTriggered: {
            lockoutTime--
            
            if (lockoutTime <= 0) {
                console.log("Lockout expired")
                isLocked = false
                attemptCount = 0
                stop()
                lockoutExpired()
            }
        }
    }
    
    
    // ============ INITIALIZATION ============
    
    Component.onCompleted: {
        console.log("PAM Authentication initialized")
        console.log("Config:", pamConfigDirectory + "/" + pamConfig)
        console.log("Max attempts:", maxAttempts)
    }
}
