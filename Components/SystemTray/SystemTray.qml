import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import "../Structure"

Module {
    id: systemTrayModule
    
    visible: SystemTray.items.values.length > 0
    
    Row {
        anchors.centerIn: parent
        spacing: 8
        
        Repeater {
            model: SystemTray.items
            
            Item {
                id: trayIcon
                width: 16
                height: 16
                
                required property var modelData
                
                Image {
                    anchors.fill: parent
                    source: {
                        let iconSource = modelData.icon.toString()
                        // Handle custom path icons (e.g., Spotify)
                        if (iconSource.includes("?path=")) {
                            let match = iconSource.match(/image:\/\/icon\/([^?]+)\?path=(.+)/)
                            if (match) {
                                let iconName = match[1]
                                let iconPath = match[2]
                                return "file://" + iconPath + "/" + iconName + ".png"
                            }
                        }
                        return modelData.icon
                    }
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    cache: false
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: (mouse) => {
                        console.log("Clicked tray item:", trayIcon.modelData.id, "button:", mouse.button)
                        if (mouse.button === Qt.LeftButton) {
                            console.log("Activating...")
                            trayIcon.modelData.activate()
                        } else if (mouse.button === Qt.RightButton) {
                            console.log("Right click, hasMenu:", trayIcon.modelData.hasMenu)
                            if (trayIcon.modelData.hasMenu) {
                                if (panel) {
                                    // Map mouse coordinates to window coordinates
                                    let globalPos = mouseArea.mapToItem(panel.contentItem, mouse.x, mouse.y)
                                    trayIcon.modelData.display(panel, globalPos.x, globalPos.y)
                                } else {
                                    console.log("ERROR: panel is null")
                                }
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            console.log("Middle click...")
                            trayIcon.modelData.secondaryActivate()
                        }
                    }
                    
                    onWheel: (wheel) => {
                        trayIcon.modelData.scroll(wheel.angleDelta.y, false)
                    }
                }
            }
        }
    }
}
