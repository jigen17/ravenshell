pragma Singleton
import QtQuick
import Quickshell

Singleton {
    enum AnimationType {
        Popup,          // Scale from center with fade (0)
        SlideDown,      // Slide down from top (1)
        SlideUp,        // Slide up from bottom (2)
        SlideLeft,      // Slide from right to left (3)
        SlideRight,     // Slide from left to right (4)
        Fade,           // Simple fade in/out (5)
        Bounce,         // Spring bounce effect (6)
        ZoomIn,         // Aggressive zoom from tiny (7)
        FlipHorizontal, // 3D flip around Y axis (8)
        FlipVertical,   // 3D flip around X axis (9)
        SlideScale,     // Slide + scale combined (10)
        Swing,          // Swing in like a door (11)
        RubberBand,     // Elastic stretch effect (12)
        LiftUp,         // Subtle lift with fade (13)
        RollIn          // Roll in like a scroll (14)
    }
}
