import QtQuick
import Quickshell.Io
import "../Structure"

ModulePopup {
    id: debugPopup
    property var stylePath: ["bar", "popup", "mediaDebug"]
    
    popupHeight: 430
    popupWidth: 350
    
    // Process for copying to clipboard
    property var clipboardProcess: Process {
        running: false
        command: []
    }
    
    Column {
        anchors.fill: parent
        spacing: 8
        
        // Header
        Text {
            text: "🐛 Media Debug Info"
            color: config.getStyle(stylePath, "textColor")
            font.pixelSize: 14
            font.bold: true
        }
        
        Rectangle {
            width: parent.width
            height: 1
            color: config.getStyle(stylePath, "borderColor")
        }
        
        // Debug fields
        Column {
            width: parent.width
            spacing: 4
            
            DebugRow { label: "Player"; value: mediaService.playerName || "(none)" }
            DebugRow { label: "Status"; value: mediaService.status }
            DebugRow { label: "Title"; value: mediaService.title || "(none)" }
            DebugRow { label: "Artist"; value: mediaService.artist || "(none)" }
            DebugRow { label: "Album"; value: mediaService.album || "(none)" }
            
            Rectangle {
                width: parent.width
                height: 1
                color: config.getStyle(stylePath, "dimColor")
                opacity: 0.3
            }
            
            DebugRow { 
                label: "Position"; 
                value: mediaService.position.toLocaleString() + " µs (" + formatTime(mediaService.position) + ")"
            }
            DebugRow { 
                label: "Length"; 
                value: mediaService.length.toLocaleString() + " µs (" + formatTime(mediaService.length) + ")"
            }
            DebugRow { label: "Volume"; value: (mediaService.volume * 100).toFixed(0) + "%" }
            DebugRow { label: "isLive"; value: mediaService.isLive ? "true" : "false"; highlight: mediaService.isLive }
            
            Rectangle {
                width: parent.width
                height: 1
                color: config.getStyle(stylePath, "dimColor")
                opacity: 0.3
            }
            
            DebugRow { label: "canControl"; value: mediaService.canControl ? "true" : "false" }
            DebugRow { label: "canPlay"; value: mediaService.canPlay ? "true" : "false" }
            DebugRow { label: "canPause"; value: mediaService.canPause ? "true" : "false" }
            DebugRow { label: "canGoPrevious"; value: mediaService.canGoPrevious ? "true" : "false" }
            DebugRow { label: "canGoNext"; value: mediaService.canGoNext ? "true" : "false" }
        }
        
        Rectangle {
            width: parent.width
            height: 1
            color: config.getStyle(stylePath, "borderColor")
        }
        
        // Raw output section
        Column {
            width: parent.width
            spacing: 4
            
            Text {
                text: "Raw playerctl output (click to copy):"
                color: config.getStyle(stylePath, "dimColor")
                font.pixelSize: 10
            }
            
            MouseArea {
                width: parent.width
                height: 60
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    clipboardProcess.command = ["wl-copy", mediaService.rawMetadata]
                    clipboardProcess.running = true
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: parent.containsMouse ? config.getStyle(stylePath, "accentColor") : config.getStyle(stylePath, "hoverColor")
                    radius: 4
                    opacity: parent.containsMouse ? 0.3 : 1.0
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
                
                Text {
                    anchors.fill: parent
                    anchors.margins: 6
                    text: mediaService.rawMetadata || "(no data)"
                    color: config.getStyle(stylePath, "textColor")
                    font.family: "monospace"
                    font.pixelSize: 9
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                }
            }
        }
    }
    
    // Helper function to format microseconds to MM:SS
    function formatTime(microseconds) {
        if (microseconds <= 0 || microseconds >= 9223372036854775807) return "--:--"
        var totalSeconds = Math.floor(microseconds / 1000000)
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }
    
    // Reusable debug row component
    component DebugRow: Row {
        property string label: ""
        property string value: ""
        property bool highlight: false
        
        width: parent.width
        spacing: 8
        
        Text {
            width: 90
            text: label + ":"
            color: config.getStyle(debugPopup.stylePath, "dimColor")
            font.pixelSize: 11
            font.family: "monospace"
            horizontalAlignment: Text.AlignRight
        }
        
        Text {
            width: parent.width - 98
            text: value
            color: highlight ? config.getStyle(debugPopup.stylePath, "accentColor") : config.getStyle(debugPopup.stylePath, "textColor")
            font.pixelSize: 11
            font.family: "monospace"
            elide: Text.ElideRight
        }
    }
}
