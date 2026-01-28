pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../assets/Fuzzy.js" as Fuzzy

Singleton {
    id: root

    // Core properties
    property var applications: DesktopEntries.applications.values
    property var searchResults: applications
    property string currentQuery: ""
    
    // Category filtering
    property string selectedCategory: "" // Empty = all categories
    
    // Recent apps tracking
    property var recentApps: []
    property int maxRecentApps: 10
    
    // Favorites
    property var favoriteApps: []
    
    // Prepared apps for fuzzy search (cached)
    property var preppedApps: []
    
    // Stats
    readonly property int totalAppsCount: applications.length
    readonly property int searchResultsCount: searchResults.length
    
    // Initialize on startup
    Component.onCompleted: {
        updatePreppedApps();
        loadRecentApps();
        loadFavorites();
        
        // Debug: Print some app categories
        for (let i = 0; i < Math.min(5, applications.length); i++) {
            const app = applications[i];
            console.log("App:", app.name, "Categories:", JSON.stringify(app.categories));
        }
    }
    
    // Watch for changes in applications
    onApplicationsChanged: {
        updatePreppedApps();
    }
    
    // Update prepared apps for fuzzy search
    function updatePreppedApps() {
        preppedApps = applications.map(app => ({
            "name": Fuzzy.prepare(app.name || ""),
            "comment": Fuzzy.prepare(app.comment || ""),
            "exec": Fuzzy.prepare(app.exec || ""),
            "entry": app
        }));
    }
    
    // Set category filter
    function setCategory(category) {
        selectedCategory = category || "";
        searchApplications(currentQuery);
    }
    
    // Clear category filter
    function clearCategory() {
        selectedCategory = "";
        searchApplications(currentQuery);
    }
    
    // Check if app matches category
    function appMatchesCategory(app, category) {
        if (!category || category === "") {
            return true; // No filter, all apps match
        }
        
        if (!app.categories) {
            return false;
        }
        
        // Handle QML list<string> - iterate with index
        const catCount = app.categories.length;
        for (let i = 0; i < catCount; i++) {
            const cat = app.categories[i];
            
            // Direct match
            if (cat === category) {
                return true;
            }
            
            // Handle AudioVideo vs Audio/Video
            if (category === "AudioVideo" && (cat === "Audio" || cat === "Video")) {
                return true;
            }
            if ((category === "Audio" || category === "Video") && cat === "AudioVideo") {
                return true;
            }
        }
        
        return false;
    }
    
    // Get filtered apps by category
    function getFilteredApps() {
        if (!selectedCategory || selectedCategory === "") {
            return applications;
        }
        
        const filtered = applications.filter(app => appMatchesCategory(app, selectedCategory));
        console.log("AppService: Filtered", applications.length, "to", filtered.length, "apps for category:", selectedCategory);
        return filtered;
    }
    
    // Main search function
    function searchApplications(query) {
        currentQuery = query;
        
        // Get base set of apps (filtered by category if set)
        const baseApps = getFilteredApps();
        
        // If query is empty, show recent apps first, then all filtered apps
        if (!query || query.length === 0) {
            const recent = getRecentApplications().filter(app =>
                appMatchesCategory(app, selectedCategory)
            );
            const remaining = baseApps.filter(app => 
                !recent.some(r => r.id === app.id)
            );
            searchResults = [...recent, ...remaining];
            return searchResults;
        }
        
        // Prepare apps for search (only the filtered ones)
        const preppedFiltered = baseApps.map(app => ({
            "name": Fuzzy.prepare(app.name || ""),
            "comment": Fuzzy.prepare(app.comment || ""),
            "exec": Fuzzy.prepare(app.exec || ""),
            "entry": app
        }));
        
        if (preppedFiltered.length === 0) {
            searchResults = [];
            return searchResults;
        }
        
        const results = Fuzzy.go(query, preppedFiltered, {
            "all": false,
            "keys": ["name", "comment", "exec"],
            "scoreFn": r => {
                const nameScore = r[0]?.score || 0;
                const commentScore = r[1]?.score || 0;
                const execScore = r[2]?.score || 0;
                const app = r.obj.entry;
                const appName = app.name || "";
                const queryLower = query.toLowerCase();
                const nameLower = appName.toLowerCase();
                
                if (nameScore === 0) {
                    return commentScore * 0.5 + execScore * 0.3;
                }
                
                let favoriteBoost = isFavorite(app.id) ? 1.5 : 1.0;
                let recentBoost = isRecent(app.id) ? 1.3 : 1.0;
                
                if (nameLower === queryLower) {
                    return nameScore * 100 * favoriteBoost * recentBoost;
                }
                
                if (nameLower.startsWith(queryLower)) {
                    return nameScore * 50 * favoriteBoost * recentBoost;
                }
                
                if (nameLower.includes(" " + queryLower) || 
                    nameLower.includes(queryLower + " ") || 
                    nameLower.endsWith(" " + queryLower)) {
                    return nameScore * 25 * favoriteBoost * recentBoost;
                }
                
                if (nameLower.includes(queryLower)) {
                    return nameScore * 10 * favoriteBoost * recentBoost;
                }
                
                return (nameScore * 2 + commentScore * 0.5 + execScore * 0.3) * favoriteBoost * recentBoost;
            },
            "limit": 50
        });
        
        searchResults = results.map(r => r.obj.entry);
        return searchResults;
    }
    
    // Launch application
    function launchApplication(app) {
        if (!app || !app.launch) {
            console.error("AppService: Invalid application or no launch method");
            return false;
        }
        
        try {
            app.launch();
            addToRecent(app);
            return true;
        } catch (e) {
            console.error("AppService: Failed to launch", app.name, ":", e);
            return false;
        }
    }
    
    // Recent apps management
    function addToRecent(app) {
        if (!app || !app.id) return;
        
        recentApps = recentApps.filter(id => id !== app.id);
        recentApps.unshift(app.id);
        
        if (recentApps.length > maxRecentApps) {
            recentApps = recentApps.slice(0, maxRecentApps);
        }
        
        saveRecentApps();
    }
    
    function getRecentApplications() {
        return recentApps
            .map(id => applications.find(app => app.id === id))
            .filter(app => app !== undefined);
    }
    
    function isRecent(appId) {
        return recentApps.includes(appId);
    }
    
    function clearRecent() {
        recentApps = [];
        saveRecentApps();
    }
    
    // Favorites management
    function toggleFavorite(app) {
        if (!app || !app.id) return;
        
        if (isFavorite(app.id)) {
            favoriteApps = favoriteApps.filter(id => id !== app.id);
        } else {
            favoriteApps.push(app.id);
        }
        
        saveFavorites();
    }
    
    function isFavorite(appId) {
        return favoriteApps.includes(appId);
    }
    
    function getFavoriteApplications() {
        return favoriteApps
            .map(id => applications.find(app => app.id === id))
            .filter(app => app !== undefined);
    }
    
    // Persistence helpers
    function saveRecentApps() {
        // Store in memory for now
    }
    
    function loadRecentApps() {
        // Load from storage
    }
    
    function saveFavorites() {
        // Store favorites
    }
    
    function loadFavorites() {
        // Load favorites
    }
    
    // Helper functions
    function getAppById(appId) {
        return applications.find(app => app.id === appId);
    }
    
    function getAppByName(name) {
        return applications.find(app => 
            app.name && app.name.toLowerCase() === name.toLowerCase()
        );
    }
    
    function getAppsByCategory(category) {
        const filtered = applications.filter(app => appMatchesCategory(app, category));
        return filtered;
    }
    
    // Clear search and reset
    function clearSearch() {
        currentQuery = "";
        selectedCategory = "";
        searchResults = applications;
    }
}
