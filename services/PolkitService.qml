pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root
    
    // Public properties
    readonly property bool authenticationRequestActive: polkitAgent.isActive
    readonly property alias authFlow: polkitAgent.flow
    readonly property bool isActive: polkitAgent.isActive
    // Signals
    signal authenticationRequestStarted()
    signal authenticationSucceeded()
    signal authenticationFailed()
    signal authenticationCancelled()
    signal authenticationCompleted()
    
    // Internal agent
    PolkitAgent {
        id: polkitAgent
        
        onAuthenticationRequestStarted: {
            console.log("Polkit: Authentication request started");
            console.log("  Action ID:", flow.actionId);
            console.log("  Message:", flow.message);
            root.authenticationRequestStarted();
        }
    }
    
    // Monitor auth flow state changes
 
    
}
