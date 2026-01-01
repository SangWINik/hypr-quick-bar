import QtQuick
import "../Structure"

ModulePopup {
    id: internetPopup
    
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
                color: appTheme.colors.fg
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
                    color: appTheme.colors.fg
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Text {
                    text: internetService.isConnected ? "Connected" : "Not connected"
                    color: appTheme.colors.fg_a60
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
                    color: appTheme.colors.fg_a60
                    font.pixelSize: 12
                    width: 70
                }
                
                Text {
                    text: internetService.deviceName || "N/A"
                    color: appTheme.colors.fg
                    font.pixelSize: 12
                }
            }
            
            Row {
                width: parent.width
                spacing: 8
                
                Text {
                    text: "IP Address:"
                    color: appTheme.colors.fg_a60
                    font.pixelSize: 12
                    width: 70
                }
                
                Text {
                    text: internetService.ipAddress || "N/A"
                    color: appTheme.colors.fg
                    font.pixelSize: 12
                }
            }
            
            Row {
                width: parent.width
                spacing: 8
                visible: internetService.connectionType === "wifi"
                
                Text {
                    text: "Signal:"
                    color: appTheme.colors.fg_a60
                    font.pixelSize: 12
                    width: 70
                }
                
                Text {
                    text: internetService.wifiSignalStrength + "%"
                    color: appTheme.colors.fg
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
                color: internetService.wifiToggling ? appTheme.colors.fg_a10 : (parent.containsMouse ? appTheme.colors.fg_a30 : appTheme.colors.fg_a10)
                radius: 6
                opacity: internetService.wifiToggling ? 0.6 : 1.0
                
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    // Loading spinner or icon
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: internetService.wifiToggling ? "󰦖" : (internetService.wifiEnabled ? "󰖪" : "󰖩")
                        color: appTheme.colors.fg
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
                        color: appTheme.colors.fg
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
