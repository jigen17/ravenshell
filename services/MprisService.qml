pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
  id: root
  
  property var players: Mpris.players.values
  property var activePlayer: {
    // First try to find a playing player
    let playing = players.find(player => player.isPlaying);
    if (playing) return playing;
    
    // Otherwise, use a paused player (or any player with media)
    return players.find(player => 
      player.playbackState !== MprisPlaybackState.Stopped
    ) || players[0]; // fallback to first player if all stopped
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
