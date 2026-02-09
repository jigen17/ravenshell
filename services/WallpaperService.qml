pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Qt.labs.folderlistmodel
import qs.config

Singleton {
    id: root
    
    // Configuration
    property string wallpaperDir: Qt.resolvedUrl(Settings.config.wallpapers.directory)
    property string currentWallpaper: Settings.config.wallpapers.path
    
    // Optimized cached filtered list
    property var filteredWallpaperList: []
    
    // Expose the folder model as an alias
    property alias wallpapers: folderModel
    
    // Expose the quantized colors
    
    // Dynamically populates from the wallpaper directory
    FolderListModel {
        id: folderModel
        folder: root.wallpaperDir
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp", "*.gif"]
        showDirs: false
        showDotAndDotDot: false
        showHidden: false
        sortField: FolderListModel.Name
        sortReversed: false
    }
    
    // Connections to update filtered list when folder contents change
    Connections {
        target: folderModel
        function onCountChanged() {
            root.updateFilteredList();
        }
    }
    
    // Initialize on component creation
    Component.onCompleted: {
        updateFilteredList();
    }
    
    // Optimized function to update the filtered wallpaper list
    function updateFilteredList() {
        const result = [];
        
        for (let i = 0; i < folderModel.count; i++) {
            const filePath = folderModel.get(i, "filePath");
            result.push(filePath);
        }
        
        filteredWallpaperList = result;
    }
        
    // Set and apply the wallpaper
    function setWallpaper(path) {
        if (!path || path === "") {
            console.warn("WallpaperService: Invalid wallpaper path");
            return;
        }
        // Update current wallpaper
        currentWallpaper = path;
        Settings.config.wallpapers.path = path;
        // Trigger wallpaper service (e.g., wallust, pywal, etc.)
        WallustService.startWallustService();
    }
    /*
    ColorQuantizer {
        id: colorQuantizer
        rescaleSize: 64  // Rescale for faster processing (recommended)
        depth: 3  // Will produce 8 colors (2³)
        source: root.currentWallpaper ? Qt.resolvedUrl(root.currentWallpaper) : ""
        
        onSourceChanged: {
            console.log("ColorQuantizer source changed to:", source);
        }
        
        onColorsChanged: {
            // Colors is a readonly list<color>, so we iterate differently
            console.log("ColorQuantizer extracted", colors.length, "colors from wallpaper");
            
            // Log each color
            for (var i = 0; i < colors.length; i++) {
                console.log("  Color " + i + ":", colors[i]);
            }
        }
    }*/
}
