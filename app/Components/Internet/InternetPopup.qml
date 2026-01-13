import QtQuick
import "../Structure"

ModulePopup {
    id: internetPopup
    property var stylePath: ["bar", "popup", "internet"]
    
    popupHeight: contentColumn.implicitHeight + 40
    popupWidth: 250
    
    Column {
        id: contentColumn
        anchors.centerIn: parent
        width: parent.width - 20
        spacing: 12
        
        // Connection status header
        Row {
            width: parent.width
            spacing: 8
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
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
                color: config.getStyle(stylePath, "textColor")
                font.family: "NotoSansMono Nerd Font"
                font.pixelSize: 24
            }
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                
                Text {
                    text: {
                        if (!internetService.isConnected || internetService.connectionType === "disconnected") {
                            return "Disconnected";
                        } else if (internetService.connectionType === "ethernet") {
                            return "Ethernet";
                        } else if (internetService.connectionType === "wifi") {
                            return internetService.wifiSSID || "WiFi";
                        } else {
                            return "Unknown";
                        }
                    }
                    color: config.getStyle(stylePath, "textColor")
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Text {
                    text: internetService.isConnected ? "Connected" : "Not connected"
                    color: config.getStyle(stylePath, "dimColor")
                    font.pixelSize: 12
                }
            }
        }
        
        // Connection details
        Column {
            width: parent.width
            spacing: 6
            visible: internetService.isConnected
            
            Row {
                width: parent.width
                spacing: 8
                
                Text {
                    text: "Device:"
                    color: config.getStyle(stylePath, "dimColor")
                    font.pixelSize: 12
                    width: 70
                }
                
                Text {
                    text: internetService.deviceName || "N/A"
                    color: config.getStyle(stylePath, "textColor")
                    font.pixelSize: 12
                }
            }
            
            Row {
                width: parent.width
                spacing: 8
                
                Text {
                    text: "IP Address:"
                    color: config.getStyle(stylePath, "dimColor")
                    font.pixelSize: 12
                    width: 70
                }
                
                Text {
                    text: internetService.ipAddress || "N/A"
                    color: config.getStyle(stylePath, "textColor")
                    font.pixelSize: 12
                }
            }
            
            Row {
                width: parent.width
                spacing: 8
                visible: internetService.connectionType === "wifi"
                
                Text {
                    text: "Signal:"
                    color: config.getStyle(stylePath, "dimColor")
                    font.pixelSize: 12
                    width: 70
                }
                
                Text {
                    text: internetService.wifiSignalStrength + "%"
                    color: config.getStyle(stylePath, "textColor")
                    font.pixelSize: 12
                }
            }
        }
        
        // WiFi toggle button
        MouseArea {
            width: parent.width
            height: 32
            hoverEnabled: true
            enabled: !internetService.wifiToggling
            
            onClicked: {
                internetService.toggleWifi()
            }
            
            Rectangle {
                anchors.fill: parent
                color: internetService.wifiToggling ? config.getStyle(stylePath, "dimColor") : (parent.containsMouse ? config.getStyle(stylePath, "hoverColor") : config.getStyle(stylePath, "dimColor"))
                radius: 6
                opacity: internetService.wifiToggling ? 0.6 : 1.0
                
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    // Loading spinner or icon
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: internetService.wifiToggling ? "󰦖" : (internetService.wifiEnabled ? "󰖪" : "󰖩")
                        color: config.getStyle(stylePath, "textColor")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 16
                        rotation: internetService.wifiToggling ? undefined : 0
                        
                        RotationAnimation on rotation {
                            running: internetService.wifiToggling
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 1000
                        }
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: internetService.wifiToggling ? "Toggling WiFi..." : (internetService.wifiEnabled ? "Disable WiFi" : "Enable WiFi")
                        color: config.getStyle(stylePath, "textColor")
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
