import QtQuick
import "../Structure"

ModulePopup {
    id: clockPopup
    property var stylePath: ["bar", "popup", "clock"]
    
    popupHeight: 260
    popupWidth: 260
    
    Item {
        anchors.centerIn: parent
        width: 220
        height: 220
        
        // Clock face background
        Rectangle {
            id: clockFace
            anchors.centerIn: parent
            width: 220
            height: 220
            radius: 110
            color: config.getStyle(stylePath, "backgroundColor", "#e61e1e2e")
            border.color: config.getStyle(stylePath, "borderColor", "#4dcdd6f4")
            border.width: 2
            
            // Hour markers
            Repeater {
                model: 12
                
                Rectangle {
                    x: clockFace.width / 2 - width / 2
                    y: 10
                    width: index % 3 === 0 ? 3 : 2
                    height: index % 3 === 0 ? 12 : 8
                    color: config.getStyle(stylePath, "dimColor", "#99cdd6f4")
                    transformOrigin: Item.Top
                    
                    transform: [
                        Translate { y: 0 },
                        Rotation {
                            origin.x: 0
                            origin.y: 100
                            angle: index * 30
                        }
                    ]
                }
            }
            
            // Center dot
            Rectangle {
                anchors.centerIn: parent
                width: 12
                height: 12
                radius: 6
                color: config.getStyle(stylePath, "accentColor", "#89b4fa")
                z: 10
            }
        }
        
        // Hour hand
        Rectangle {
            id: hourHand
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height
            width: 6
            height: 60
            radius: 3
            color: config.getStyle(stylePath, "textColor", "#cdd6f4")
            transformOrigin: Item.Bottom
            antialiasing: true
            
            rotation: {
                var time = timeService.currentTime
                var hours = time.getHours() % 12
                var minutes = time.getMinutes()
                return (hours * 30) + (minutes * 0.5)
            }
        }
        
        // Minute hand
        Rectangle {
            id: minuteHand
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height
            width: 4
            height: 85
            radius: 2
            color: config.getStyle(stylePath, "textColor", "#cdd6f4")
            transformOrigin: Item.Bottom
            antialiasing: true
            
            rotation: {
                var time = timeService.currentTime
                var minutes = time.getMinutes()
                var seconds = time.getSeconds()
                return (minutes * 6) + (seconds * 0.1)
            }
        }
        
        // Second hand
        Rectangle {
            id: secondHand
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height
            width: 2
            height: 95
            radius: 1
            color: config.getStyle(stylePath, "accentColor", "#89b4fa")
            transformOrigin: Item.Bottom
            antialiasing: true
            
            rotation: {
                var time = timeService.currentTime
                return time.getSeconds() * 6
            }
            
            Behavior on rotation {
                RotationAnimation {
                    duration: 100
                    direction: RotationAnimation.Clockwise
                }
            }
        }
        
        // Digital time display at bottom
        /* Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            text: Qt.formatDateTime(timeService.currentTime, "HH:mm:ss")
            color: appTheme.colors.fg
            font.pixelSize: 16
            font.bold: true
        } */
    }
}
