import QtQuick
import "../Structure"

Module {
    id: mediaModule
    
    // Setting: show all controls when paused (true) or just play button (false)
    property bool showControlsWhenPaused: true
    
    // Setting: show volume controls (true) or hide them (false)
    property bool showVolumeControls: false
    
    visible: mediaService.hasActiveMedia
    horizontalPadding: 4
    
    enableClickArea: false
    enableHover: false
    
    // Computed property for control visibility
    readonly property bool showAllControls: mediaService.status === "Playing" || showControlsWhenPaused
    
    // Unified layout for both states
    Row {
        id: content
        anchors.centerIn: parent
        spacing: 8
        
        // Play/Pause button (always visible)
        MouseArea {
            id: playPauseButton
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            hoverEnabled: true
            onClicked: {
                if (mediaService.status === "Playing") {
                    mediaService.pause()
                } else {
                    mediaService.play()
                }
            }
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                
                Text {
                    anchors.centerIn: parent
                    text: mediaService.status === "Playing" ? "󰏤" : "󰐊"
                    color: appTheme.colors.fg
                    font.family: "NotoSansMono Nerd Font"
                    font.pixelSize: 18
                }
            }
        }
        
        // Separator
        Rectangle {
            visible: showAllControls
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 16
            color: appTheme.colors.fg_a30
        }
        
        // Previous button
        MouseArea {
            id: previousButton
            visible: showAllControls && !mediaService.isLive
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            hoverEnabled: true
            enabled: mediaService.canGoPrevious
            onClicked: mediaService.previous()
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                opacity: parent.enabled ? 1.0 : 0.3
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: appTheme.colors.fg
                    font.family: "NotoSansMono Nerd Font"
                    font.pixelSize: 16
                }
            }
        }
        
        // Media info and timeline
        Column {
            visible: showAllControls
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            width: 250
            
            // Title with LIVE indicator
            Row {
                width: parent.width
                spacing: 6
                
                // Red circle LIVE indicator
                Rectangle {
                    id: liveIndicator
                    visible: mediaService.isLive
                    anchors.verticalCenter: parent.verticalCenter
                    width: 8
                    height: 8
                    radius: 4
                    color: "#ef4444"
                }
                
                Text {
                    width: parent.width - (liveIndicator.visible ? liveIndicator.width + parent.spacing : 0)
                    text: {
                        var fullText = mediaService.title
                        if (mediaService.artist) {
                            fullText += " - " + mediaService.artist
                        }
                        return fullText
                    }
                    color: appTheme.colors.fg
                    font.pixelSize: appConfig.fontSize - 3
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }
            }
            
            // Timeline
            Item {
                visible: !mediaService.isLive
                width: parent.width
                height: 10
                
                // Background track
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 4
                    color: appTheme.colors.fg_a30
                    radius: 2
                    
                    // Progress bar
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: mediaService.length > 0 ? (mediaService.position / mediaService.length) * parent.width : 0
                        height: parent.height
                        color: appTheme.colors.fg
                        radius: 2
                    }
                }
                
                // Interactive overlay for seeking
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    onClicked: (mouse) => {
                        if (mediaService.length > 0) {
                            var ratio = mouse.x / width
                            var newPosition = ratio * mediaService.length
                            mediaService.seek(newPosition)
                        }
                    }
                    
                    // Visual feedback
                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? appTheme.colors.fg_a10 : "transparent"
                        radius: 2
                    }
                }
            }
        }
        
        // Next button
        MouseArea {
            id: nextButton
            visible: showAllControls && !mediaService.isLive
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            hoverEnabled: true
            enabled: mediaService.canGoNext
            onClicked: mediaService.next()
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                opacity: parent.enabled ? 1.0 : 0.3
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: appTheme.colors.fg
                    font.family: "NotoSansMono Nerd Font"
                    font.pixelSize: 16
                }
            }
        }
        
        // Separator before volume
        Rectangle {
            visible: showAllControls && showVolumeControls
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 16
            color: appTheme.colors.fg_a30
        }
        
        // Volume button
        MouseArea {
            id: volumeButton
            visible: showAllControls && showVolumeControls
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            hoverEnabled: true
            onClicked: popupManager.togglePopup(volumePopup)
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                
                Text {
                    anchors.centerIn: parent
                    text: {
                        if (mediaService.volume === 0) {
                            return "󰝟"
                        } else if (mediaService.volume < 0.33) {
                            return "󰕿"
                        } else if (mediaService.volume < 0.66) {
                            return "󰖀"
                        } else {
                            return "󰕾"
                        }
                    }
                    color: appTheme.colors.fg
                    font.family: "NotoSansMono Nerd Font"
                    font.pixelSize: 16
                }
            }
        }
    }
    
    // Close popup when media stops playing
    Connections {
        target: mediaService
        
        function onStatusChanged() {
            if (mediaService.status !== "Playing" && volumePopup.visible) {
                popupManager.closeCurrentPopup()
            }
        }
    }
    
    VolumePopup {
        id: volumePopup
        targetModule: volumeButton
    }
}
