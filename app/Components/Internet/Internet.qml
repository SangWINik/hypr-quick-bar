import Quickshell.Io
import QtQuick
import "../Structure"

Module {
    id: internetModule
    // Style path
    stylePath: ["bar", "section", "module", "components", "internet"]

    width: 45
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(internetPopup)
    
    Text {
        anchors.centerIn: parent
        text: {
            if (!internetService.isConnected || internetService.connectionType === "disconnected") {
                return "󰖪"; // Disconnected icon
            } else if (internetService.connectionType === "ethernet") {
                return "󰛳"; // Ethernet icon
            } else if (internetService.connectionType === "wifi") {
                // WiFi icons based on signal strength
                if (internetService.wifiSignalStrength >= 75) {
                    return "󰤨"; // Full signal
                } else if (internetService.wifiSignalStrength >= 50) {
                    return "󰤥"; // Good signal
                } else if (internetService.wifiSignalStrength >= 25) {
                    return "󰤢"; // Medium signal
                } else if (internetService.wifiSignalStrength > 0) {
                    return "󰤟"; // Weak signal
                } else {
                    return "󰤯"; // No signal
                }
            } else {
                return "󰖪"; // Unknown/disconnected
            }
        }
        color: internetService.isConnected ? config.getStyle(internetModule.stylePath, "textColor") : config.getStyle(internetModule.stylePath, "errorColor")
        font.family: "NotoSansMono Nerd Font"
        font.pixelSize: config.getStyle(internetModule.stylePath, "fontSize") + 4
    }
    
    InternetPopup {
        id: internetPopup
        targetModule: internetModule
    }
}
