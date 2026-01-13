import QtQuick
import "../Structure"

Module {
    id: weatherModule
    
    // Style path
    stylePath: ["bar", "section", "module", "components", "weather"]
    
    // Using simple width estimation or auto
    // width: weatherText.implicitWidth + 20
    
    visible: weatherService.weatherCode !== -1
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(weatherPopup)
    
    Text {
        id: weatherText
        anchors.centerIn: parent
        text: {
            if (weatherService.weatherCode === -1) return "󰖪"; // N/A icon
            
            var icon = weatherService.getWeatherIcon(weatherService.weatherCode);
            return icon + " " + weatherService.temperature;
        }
        
        color: config.getStyle(weatherModule.stylePath, "textColor")
        font.family: "NotoSansMono Nerd Font"
        font.pixelSize: config.getStyle(weatherModule.stylePath, "fontSize")
    }
    
    WeatherPopup {
        id: weatherPopup
        targetModule: weatherModule
    }
}
