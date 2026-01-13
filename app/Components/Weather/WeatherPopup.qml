import QtQuick
import "../Structure"

ModulePopup {
    id: weatherPopup
    property var stylePath: ["bar", "popup", "weather"]
    
    popupHeight: 360
    popupWidth: 300
    
    Column {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 30
        spacing: 16
        
        // Header Group
        Column {
            width: parent.width
            spacing: -5
            
            // Current Weather Big Icon
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12
                
                Text {
                    text: weatherService.getWeatherIcon(weatherService.weatherCode)
                    color: config.getStyle(stylePath, "accentColor", "#89b4fa")
                    font.family: "NotoSansMono Nerd Font"
                    font.pixelSize: 48
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: weatherService.temperature
                    color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                    font.pixelSize: 32
                    font.bold: true
                }
            }
    
            // Location Header
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: (weatherService.locationName || "Detecting...") + " • " + Qt.formatDateTime(new Date(), "ddd, MMM d")
                color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                font.pixelSize: 15
                font.bold: true
                elide: Text.ElideRight
            }
        }
        
        Rectangle {
            width: parent.width
            height: 1
            color: config.getStyle(stylePath, "textColorDim", "#bac2de")
            opacity: 0.3
        }
        
        // Forecast List
        Column {
            width: parent.width
            spacing: 8
            
            Repeater {
                model: weatherService.forecast
                
                Row {
                    width: parent.width
                    
                    Text {
                        width: 50
                        text: modelData.day
                        color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.pixelSize: 13
                    }
                    
                    Text {
                        width: 40
                        text: weatherService.getWeatherIcon(modelData.code)
                        color: config.getStyle(stylePath, "accentColor", "#89b4fa")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Item {
                        width: parent.width - 90
                        height: parent.height
                        
                        Text {
                            anchors.right: parent.right
                            text: modelData.max + " / " + modelData.min
                            color: config.getStyle(stylePath, "textColorDim", "#bac2de")
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }
    

}
