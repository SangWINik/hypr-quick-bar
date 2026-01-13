import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire
import Quickshell.Io
import "../Structure"

ModulePopup {
    id: volumePopup
    property var stylePath: ["bar", "popup", "volume"]
    
    property real volume: 0.0
    property bool muted: false
    
    popupHeight: 90
    popupWidth: 250
    
    Process {
        id: pavucontrolProcess
        running: false
        command: ["pavucontrol"]
    }
    
    Column {
        anchors.centerIn: parent
        width: parent.width - 20
        spacing: 4
        
        // Top row: Volume display and config button
        Row {
            id: topRow
            width: parent.width
            
            // Volume display with icon
            Row {
                id: volumeRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                
                // Mute toggle button
                MouseArea {
                    id: muteButton
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    height: 28
                    hoverEnabled: true
                    
                    onClicked: {
                        if (Pipewire.defaultAudioSink?.audio) {
                            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor") : "transparent"
                        radius: 6
                        
                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (muted || volume === 0) {
                                    return "󰝟";
                                } else if (volume < 0.33) {
                                    return "󰕿";
                                } else if (volume < 0.66) {
                                    return "󰖀";
                                } else {
                                    return "󰕾";
                                }
                            }
                            color: config.getStyle(stylePath, "textColor")
                            font.family: "NotoSansMono Nerd Font"
                            font.pixelSize: 20
                        }
                    }
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(volume * 100) + "%"
                    color: config.getStyle(stylePath, "textColor")
                    font.pixelSize: 18
                    font.bold: true
                }
            }
            
            Item {
                width: parent.width - volumeRow.width - configButton.width
                height: 1
            }
            
            // Config button
            MouseArea {
                id: configButton
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                hoverEnabled: true
                
                onClicked: {
                    pavucontrolProcess.running = true
                    popupManager.closeCurrentPopup()
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor") : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰒓"  // Settings/config icon
                        color: config.getStyle(stylePath, "textColor")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 20
                    }
                }
            }
        }
        
        // Custom volume slider
        Item {
            id: volumeSlider
            width: parent.width
            height: 24
            
            Slider {
                id: qtSlider
                anchors.fill: parent
                from: 0
                to: 1.0
                value: volume
                
                onMoved: {
                    if (Pipewire.defaultAudioSink?.audio) {
                        Pipewire.defaultAudioSink.audio.volume = value;
                    }
                }
                
                background: Rectangle {
                    x: qtSlider.leftPadding
                    y: qtSlider.topPadding + qtSlider.availableHeight / 2 - height / 2
                    width: qtSlider.availableWidth
                    height: 6
                    radius: 3
                    color: config.getStyle(stylePath, "dimColor")
                    
                    Rectangle {
                        width: qtSlider.visualPosition * parent.width
                        height: parent.height
                        color: config.getStyle(stylePath, "accentColor")
                        radius: 3
                    }
                }
                
                handle: Rectangle {
                    x: qtSlider.leftPadding + qtSlider.visualPosition * (qtSlider.availableWidth - width)
                    y: qtSlider.topPadding + qtSlider.availableHeight / 2 - height / 2
                    width: 18
                    height: 18
                    radius: 9
                    color: config.getStyle(stylePath, "textColor")
                    border.color: config.getStyle(stylePath, "borderColor")
                    border.width: 2
                }
            }
        }
    }
}
