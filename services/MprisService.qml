pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
  id: root
  
property var players: Mpris.players.values
property var blackListedPlayers: ["Mozilla zen", "Youtube"]

property var allowedPlayers: players.filter(player =>
    !blackListedPlayers.includes(player.identity)
)

property var activePlayer: {
    // First try to find a playing allowed player
    let playing = allowedPlayers.find(player => player.isPlaying);
    if (playing) return playing;

    // Otherwise prefer Spotify if it's allowed
    let spotify = allowedPlayers.find(player =>
        player.identity === "Spotify"
    );
    if (spotify) return spotify;

    // fallback
    return allowedPlayers[0];
}
  function previousTrack() {
    if (activePlayer?.canControl && activePlayer?.canGoPrevious) {
      activePlayer.previous();
    }
  }
  
  function toggleTrack() {
    if (activePlayer?.canControl && activePlayer?.canTogglePlaying) {
      activePlayer.togglePlaying();
    }
  }
  
  function nextTrack() {
    if (activePlayer?.canControl && activePlayer?.canGoNext) {
      activePlayer.next();
    }
  }
}
