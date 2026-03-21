pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import qs.config

Singleton {
    id: root

    // Configuration
    property string wallpaperDir: Settings.config.wallpapers.directory
    property string currentWallpaper: Settings.config.wallpapers.path

    property var filteredWallpaperList: []
    property alias wallpapers: folderModel
    property var tags: new Set()

    readonly property ListModel results: ListModel {}

    property int  currentPage:   1
    property bool hasMorePages:  true
    property bool isFetching:    false
    property string lastQuery:   ""

    // Track what we're about to set after download
    property string pendingWallpaperPath: ""

    Process {
        id: downloaderProcess
        onExited: (code) => {
            if (code === 0 && root.pendingWallpaperPath !== "") {
                // Build local path from filename
                const filename = root.pendingWallpaperPath.split("/").pop();
                const localPath = root.wallpaperDir + "/" + filename;
                root.setWallpaper(localPath);
            } else if (code !== 0) {
                console.warn("WallpaperService: curl failed with code", code);
            }
            root.pendingWallpaperPath = "";
        }
    }

    function downloadAndApply(path) {
        if (downloaderProcess.running) {
            console.warn("WallpaperService: Download already in progress");
            return;
        }
        pendingWallpaperPath = path;
        downloaderProcess.command = ["curl", "-L", "--output-dir", wallpaperDir, "-O", path];
        downloaderProcess.running = true;
    }

    function searchWallpapers(query) {
        if (isFetching) return;
        lastQuery   = query;
        currentPage = 1;
        hasMorePages = true;
        results.clear();
        _fetchPage(query, 1);
    }

    function fetchNextPage() {
        if (isFetching || !hasMorePages || lastQuery === "") return;
        _fetchPage(lastQuery, currentPage + 1);
    }

    function _fetchPage(query, page) {
        isFetching = true;
        const xhr = new XMLHttpRequest();
        const params = new URLSearchParams({
            q:          query,
            categories: "111",   // general + anime + people
            purity:     "100",   // SFW only (add "110" for sketchy)
            sorting:    "date_added",
            order:      "desc",
            page:       page
        });
        xhr.open("GET", `https://wallhaven.cc/api/v1/search?${params.toString()}`);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onload = () => {
            isFetching = false;
            if (xhr.status !== 200) {
                console.warn("Wallhaven ERROR:", xhr.status);
                return;
            }
            try {
                const json = JSON.parse(xhr.responseText);
                if (!json.data?.length) {
                    hasMorePages = false;
                    console.warn("Wallhaven: No more results.");
                    return;
                }
                // Check if we've hit the last page
                const meta = json.meta;
                hasMorePages = meta ? (meta.current_page < meta.last_page) : json.data.length > 0;
                currentPage  = page;

                console.log("Wallhaven: fetched page", page, "-", json.data.length, "results");
                json.data.forEach(w => {
                    results.append({
                        wallId:     w.id,
                        url:        w.url,
                        path:       w.path,
                        thumbnail:  w.thumbs.small,
                        resolution: w.resolution,
                        ratio:      w.ratio,
                        category:   w.category,
                        tags:       (w.tags || []).map(t => t.name).join(",")
                    });
                });
            } catch (e) {
                console.warn("Wallhaven: JSON parse error:", e);
            }
        };

        xhr.onerror = () => { isFetching = false; console.warn("Wallhaven: Network error."); };
        xhr.send();
    }

    function setWallpaper(path) {
        if (!path) {
            console.warn("WallpaperService: Invalid path");
            return;
        }
        currentWallpaper = path;
        Settings.config.wallpapers.path = path;
        WallustService.startWallustService();
    }

    FolderListModel {
        id: folderModel
        folder: Qt.resolvedUrl(root.wallpaperDir)
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp", "*.gif"]
        showDirs: false
        showDotAndDotDot: false
        showHidden: false
        sortField: FolderListModel.Name
        sortReversed: false
    }

    Connections {
        target: folderModel
        function onCountChanged() { root.updateFilteredList() }
    }

    Component.onCompleted: updateFilteredList()

    function updateFilteredList() {
        const result = [];
        for (let i = 0; i < folderModel.count; i++)
            result.push(folderModel.get(i, "filePath"));
        filteredWallpaperList = result;
    }
}
