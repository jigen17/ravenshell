pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    
    // ============================
    // Public Readonly API
    // ============================
    readonly property ListModel results: ListModel {}
    readonly property bool loading: _loading
    readonly property string lastError: _lastError
    
    // ============================
    // Internal Private State
    // ============================
    property bool _loading: false
    property string _lastError: ""
    
    // ============================
    // Public Method
    // ============================
    function search(term) {
        if (!term || term.length < 2) {
            console.log("AniListService: search term too short");
            return;
        }
        
        console.log("AniListService: searching:", term);
        _loading = true;
        _lastError = "";
        results.clear();
        
        const query = `
          query ($search: String) {
            Page(perPage: 100) {
              media(search: $search, type: ANIME) {
                id
                title {
                  english
                  romaji
                }
                coverImage {
                  large
                }
                episodes
                genres
                description
              }
            }
          }
        `;
        
        const payload = {
            query: query,
            variables: {
                search: term
            }
        };
        
        const xhr = new XMLHttpRequest();
        xhr.open("POST", "https://graphql.anilist.co");
        xhr.setRequestHeader("Content-Type", "application/json");
        
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;
            
            _loading = false;
            console.log("AniListService: HTTP status:", xhr.status);
            
            if (xhr.status !== 200) {
                _lastError = "HTTP Error " + xhr.status;
                console.log("AniListService ERROR:", xhr.responseText);
                return;
            }
            
            const json = JSON.parse(xhr.responseText);
            if (!json.data) {
                _lastError = "Invalid API response";
                console.log("AniListService ERROR: No data field");
                return;
            }
            
            const mediaList = json.data.Page.media;
            console.log("AniListService: got", mediaList.length, "results");
            
            for (let i = 0; i < mediaList.length; i++) {
                const anime = mediaList[i];
                
                // Convert genres array to comma-separated string
                // This is THE FIX - ListModel can't store JS arrays properly
                const genresArray = anime.genres || [];
                const genresString = genresArray.join(",");
                
                console.log("Anime:", anime.title.romaji, "Genres:", genresString);
                
                results.append({
                    animeId: anime.id,
                    title: anime.title.english || anime.title.romaji,
                    episodes: anime.episodes || 0,
                    cover: anime.coverImage.large,
                    genres: genresString,  // Store as string!
                    description: anime.description || ""
                });
            }
        };
        
        xhr.send(JSON.stringify(payload));
    }
}
