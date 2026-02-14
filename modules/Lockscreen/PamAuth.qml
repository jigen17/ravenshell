import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    // Properties
    property string responseText: ""
    property bool sessionActive: false
    property bool isLocked: false
    readonly property int lockoutMinutes: 5

    // Signals
    signal pamError(string message)
    signal unlocked()

    // Main unlock function
    function unlock() {
        console.log("unlock() called - isLocked:", isLocked, "sessionActive:", sessionActive);
        
        if (isLocked) {
            pamError("Too many attempts. Wait " + lockoutMinutes + " minutes");
            console.log("Unlock aborted: locked out");
            return;
        }
        
        if (sessionActive) {
            console.log("Session already active, aborting");
            return;
        }
        
        if (responseText === "") {
            console.log("No password entered");
            pamError("Please enter a password");
            return;
        }
        
        console.log("Starting PAM authentication...");
        sessionActive = true;
        pamContext.start();
    }

    // PAM Context
    PamContext {
        id: pamContext

        onPamMessage: {
            console.log("PAM Message received");      
           
            if (responseRequired) {
                if (root.responseText !== "") {
                    console.log("Sending password response");
                    respond(root.responseText);
                } else {
                    console.log("No password to send");
                }
                return;
            }
            
            // Check for account lock messages
            console.log("Pam Context Message",message)
        }

        onCompleted: result => {
            console.log("PAM completed");
            console.log("  result value:", result);
            console.log("  PamResult.Success:", PamResult.Success);
            console.log("  PamResult.Failed:", PamResult.Failed);
            
            if (result === PamResult.Success) {
                console.log("Authentication successful!");
                root.unlocked();
            } else if (result === PamResult.Failed) {
                console.log("Authentication failed");
                root.pamError("Incorrect password");
            } else {
                console.log("Unknown result:", result);
                root.pamError("Authentication error");
            }
            
            // Clean up
            root.responseText = "";
            root.sessionActive = false;
        }

        onError: error => {
            console.log("PAM error:", error);
            root.pamError("PAM error: " + error.toString());
            root.sessionActive = false;
            root.responseText = "";
        }
    }

    // Lockout timer
    Timer {
        id: lockoutTimer
        interval: root.lockoutMinutes * 60000
        onTriggered: {
            console.log("Lockout period expired");
            root.isLocked = false;
        }
    }
}
