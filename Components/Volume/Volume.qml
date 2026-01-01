import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import "../Structure"

Module {
    id: volumeModule
    width: 45
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(volumePopup)
    
    property real currentVolume: 0.0
    property bool isMuted: false
    
    // Bind the default audio sink to get volume information
    PwObjectTracker {
        id: tracker
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }
    
    // Monitor changes to the default sink and its volume
    Connections {
        target: Pipewire.defaultAudioSink?.audio
        
        function onVolumeChanged() {
            if (Pipewire.defaultAudioSink?.audio) {
                volumeModule.currentVolume = Pipewire.defaultAudioSink.audio.volume;
            }
        }
        
        function onMutedChanged() {
            if (Pipewire.defaultAudioSink?.audio) {
                volumeModule.isMuted = Pipewire.defaultAudioSink.audio.muted;
            }
        }
    }
    
    // Update volume when default sink changes
    Connections {
        target: Pipewire
        
        function onDefaultAudioSinkChanged() {
            updateVolume();
        }
    }
    
    function updateVolume() {
        if (Pipewire.defaultAudioSink?.audio) {
            currentVolume = Pipewire.defaultAudioSink.audio.volume;
            isMuted = Pipewire.defaultAudioSink.audio.muted;
        }
    }
    
    Component.onCompleted: updateVolume()
    
    Row {
        anchors.centerIn: parent
        spacing: 6
        
        // Icon based on volume level
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (isMuted || currentVolume === 0) {
                    return "󰝟"; // Muted icon
                } else if (currentVolume < 0.33) {
                    return "󰕿"; // Low volume
                } else if (currentVolume < 0.66) {
                    return "󰖀"; // Medium volume
                } else {
                    return "󰕾"; // High volume
                }
            }
            color: appTheme.colors.fg
            font.family: "NotoSansMono Nerd Font"
            font.pixelSize: config.fontSize + 4
        }
        
        // Volume percentage
        /* Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(currentVolume * 100) + "%"
            color: appTheme.colors.fg
            font.family: "NotoSansMono Nerd Font"
            font.pixelSize: config.fontSize - 2
        } */
    }
    
    VolumePopup {
        id: volumePopup
        targetModule: volumeModule
        volume: volumeModule.currentVolume
        muted: volumeModule.isMuted
    }
}
