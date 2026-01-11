import QtQuick
import Quickshell.Io
import "../Structure"

ModulePopup {
    id: powerPopup
    property var stylePath: ["bar", "popup", "power"]
    
    popupHeight: contentColumn.implicitHeight + 40
    popupWidth: 180
    
    Process {
        id: powerCommand
        running: false
    }
    
    Column {
        id: contentColumn
        anchors.centerIn: parent
        width: parent.width - 20
        spacing: 8
        
        // Power Off
        MouseArea {
            width: parent.width
            height: 35
            hoverEnabled: true
            
            onClicked: {
                powerCommand.command = ["systemctl", "poweroff"]
                powerCommand.running = true
                popupManager.closeCurrentPopup()
            }
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor", "#4dcdd6f4") : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "⏻"
                        color: config.getStyle(stylePath, "errorColor", "#f38ba8")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: config.getStyle(stylePath, "fontSize", 14) + 8
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Power Off"
                        color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.pixelSize: 14
                    }
                }
            }
        }

        // Log Out
        MouseArea {
            width: parent.width
            height: 35
            hoverEnabled: true
            
            onClicked: {
                powerCommand.command = ["hyprctl", "dispatch", "exit"]
                powerCommand.running = true
                popupManager.closeCurrentPopup()
            }
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor", "#4dcdd6f4") : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰍃"
                        color: config.getStyle(stylePath, "errorColor", "#f38ba8")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 16
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Log Out"
                        color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.pixelSize: 14
                    }
                }
            }
        }
        
        // Reboot
        MouseArea {
            width: parent.width
            height: 35
            hoverEnabled: true
            
            onClicked: {
                powerCommand.command = ["systemctl", "reboot"]
                powerCommand.running = true
                popupManager.closeCurrentPopup()
            }
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor", "#4dcdd6f4") : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰜉"
                        color: config.getStyle(stylePath, "warningColor", "#f9e2af")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 18
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Reboot"
                        color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.pixelSize: 14
                    }
                }
            }
        }
        
        // Sleep
        MouseArea {
            width: parent.width
            height: 35
            hoverEnabled: true
            
            onClicked: {
                powerCommand.command = ["systemctl", "suspend"]
                powerCommand.running = true
                popupManager.closeCurrentPopup()
            }
            
            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor", "#4dcdd6f4") : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰒲"
                        color: config.getStyle(stylePath, "warningColor", "#f9e2af")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 18
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Sleep"
                        color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.pixelSize: 14
                    }
                }
            }
        }

    }
}
