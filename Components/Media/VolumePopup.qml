import QtQuick
import QtQuick.Controls
import "../Structure"

ModulePopup {
    id: volumePopup
    
    popupHeight: 180
    popupWidth: 60
    
    property real volumeBeforeMute: 0.5
    
    Column {
        anchors.centerIn: parent
        width: parent.width - 20
        spacing: 12
        
        // Vertical volume slider
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 40
            height: 140
            
            Column {
                anchors.fill: parent
                spacing: 8
                
                // Slider
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 30
                    height: parent.height - 30
                    
                    // Background track
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        width: 6
                        height: parent.height
                        color: appTheme.colors.fg_a30
                        radius: 3
                        
                        // Filled portion (from bottom)
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            height: mediaService.volume * parent.height
                            color: appTheme.colors.fg
                            radius: 3
                        }
                    }
                    
                    // Slider handle
                    Rectangle {
                        id: sliderHandle
                        y: (parent.height - height) * (1 - mediaService.volume)
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 18
                        height: 18
                        radius: 9
                        color: appTheme.colors.fg
                        border.color: appTheme.colors.bg
                        border.width: 2
                    }
                    
                    // Interactive area
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        property bool dragging: false
                        
                        onPressed: (mouse) => {
                            dragging = true
                            updateVolume(mouse.y)
                        }
                        
                        onReleased: {
                            dragging = false
                        }
                        
                        onPositionChanged: (mouse) => {
                            if (dragging) {
                                updateVolume(mouse.y)
                            }
                        }
                        
                        onClicked: (mouse) => {
                            updateVolume(mouse.y)
                        }
                        
                        function updateVolume(y) {
                            // Invert y-axis: top = 1.0, bottom = 0.0
                            var ratio = 1 - Math.max(0, Math.min(1, y / height))
                            mediaService.setVolume(ratio)
                        }
                        
                        // Visual feedback
                        Rectangle {
                            anchors.fill: parent
                            color: parent.containsMouse || parent.dragging ? appTheme.colors.fg_a10 : "transparent"
                            radius: 3
                        }
                    }
                }
                
                // Volume icon at bottom (clickable to toggle mute)
                MouseArea {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 28
                    height: 28
                    hoverEnabled: true
                    
                    onClicked: {
                        if (mediaService.volume > 0) {
                            volumePopup.volumeBeforeMute = mediaService.volume
                            mediaService.setVolume(0)
                        } else {
                            mediaService.setVolume(volumePopup.volumeBeforeMute)
                        }
                    }
                    
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
                            font.pixelSize: 20
                        }
                    }
                }
            }
        }
    }
}
