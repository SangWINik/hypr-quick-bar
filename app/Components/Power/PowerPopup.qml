import QtQuick
import Quickshell.Io
import "../Structure"

ModulePopup {
    id: powerPopup
    
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
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "⏻"
                        color: appTheme.colors.error
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: appConfig.fontSize + 8
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Power Off"
                        color: appTheme.colors.fg
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
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰍃"
                        color: appTheme.colors.error
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 16
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Log Out"
                        color: appTheme.colors.fg
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
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰜉"
                        color: appTheme.colors.warning
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 18
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Reboot"
                        color: appTheme.colors.fg
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
                color: parent.containsMouse ? appTheme.colors.fg_a30 : "transparent"
                radius: 6
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰒲"
                        color: appTheme.colors.warning
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 18
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Sleep"
                        color: appTheme.colors.fg
                        font.pixelSize: 14
                    }
                }
            }
        }

    }
}
