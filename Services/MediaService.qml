import QtQuick
import Quickshell.Io

Item {
    id: mediaService
    
    // Media state properties
    property string playerName: ""
    property string status: "Stopped"  // Playing, Paused, Stopped
    property string title: ""
    property string artist: ""
    property string album: ""
    property real position: 0.0  // Current position in microseconds
    property real length: 0.0    // Total length in microseconds
    property real volume: 0.5    // Volume 0.0 to 1.0
    property bool canControl: false
    property bool canPlay: false
    property bool canPause: false
    property bool canGoPrevious: false
    property bool canGoNext: false
    
    // Computed property for visibility
    property bool hasActiveMedia: status === "Playing" || status === "Paused"
    
    // Computed property for live streams (max int64 means unknown/infinite duration)
    property bool isLive: length == 0 || length >= 9223372036854775807
    
    // Continuous metadata monitoring process (event-based)
    property var metadataMonitor: Process {
        running: true
        command: ["playerctl", "metadata", "--follow", "--format", "{{playerName}}|{{status}}|{{title}}|{{artist}}|{{album}}|{{mpris:length}}|{{volume}}|{{position}}"]
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: line => {
                if (line.length > 0) {
                    parseMetadata(line)
                } else {
                    // Empty line means no players available
                    status = "Stopped"
                }
            }
        }
    }
    
    function parseMetadata(line) {
        var parts = line.split("|")
        if (parts.length !== 8) {
            status = "Stopped";
            console.warn("MediaService: Unexpected metadata format from playerctl:", line)
            return
        }
        
        playerName = parts[0] || ""
        status = parts[1] || "Stopped"
        title = parts[2] || "Unknown"
        artist = parts[3] || ""
        album = parts[4] || ""
        length = parseFloat(parts[5] || "0")
        volume = parseFloat(parts[6] || "0.5")
        position = parseFloat(parts[7] || "0") // for some reason Spotify reports wrong position when first started
        
        // Update capabilities
        canControl = status !== "Stopped"
        canPlay = status === "Paused"
        canPause = status === "Playing"
        canGoPrevious = canControl
        canGoNext = canControl
    }
    
    // Control processes
    property var playProcess: Process {
        running: false
        command: []
    }
    
    property var pauseProcess: Process {
        running: false
        command: []
    }
    
    property var playPauseProcess: Process {
        running: false
        command: []
    }
    
    property var previousProcess: Process {
        running: false
        command: []
    }
    
    property var nextProcess: Process {
        running: false
        command: []
    }
    
    property var volumeProcess: Process {
        running: false
        command: []
    }
    
    property var seekProcess: Process {
        running: false
        command: []
    }
    
    // Control functions
    function play() {
        playProcess.command = playerName ? ["playerctl", "-p", playerName, "play"] : ["playerctl", "play"]
        playProcess.running = true
    }
    
    function pause() {
        pauseProcess.command = playerName ? ["playerctl", "-p", playerName, "pause"] : ["playerctl", "pause"]
        pauseProcess.running = true
    }
    
    function playPause() {
        playPauseProcess.command = playerName ? ["playerctl", "-p", playerName, "play-pause"] : ["playerctl", "play-pause"]
        playPauseProcess.running = true
    }
    
    function previous() {
        previousProcess.command = playerName ? ["playerctl", "-p", playerName, "previous"] : ["playerctl", "previous"]
        previousProcess.running = true
    }
    
    function next() {
        nextProcess.command = playerName ? ["playerctl", "-p", playerName, "next"] : ["playerctl", "next"]
        nextProcess.running = true
    }
    
    function setVolume(vol) {
        var clampedVol = Math.max(0.0, Math.min(1.0, vol))
        volumeProcess.command = playerName ? ["playerctl", "-p", playerName, "volume", clampedVol.toString()] : ["playerctl", "volume", clampedVol.toString()]
        volumeProcess.running = true
        volume = clampedVol
    }
    
    function seek(positionMicroseconds) {
        var seconds = positionMicroseconds / 1000000
        seekProcess.command = playerName ? ["playerctl", "-p", playerName, "position", seconds.toString()] : ["playerctl", "position", seconds.toString()]
        seekProcess.running = true
        position = positionMicroseconds
    }
}
