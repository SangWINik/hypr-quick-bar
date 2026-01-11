import QtQuick
import "../Structure"

Module {
    id: clockModule
    
    // Define style path for this specific module
    stylePath: ["bar", "section", "module", "components", "clock"]
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(clockPopup)
    
    Text {
        anchors.centerIn: parent
        color: config.getStyle(clockModule.stylePath, "textColor", "#cdd6f4")
        font.pixelSize: config.getStyle(clockModule.stylePath, "fontSize", 14)
        text: Qt.formatDateTime(timeService.currentTime, config.getStyle(clockModule.stylePath, "format", "HH:mm"))
    }
    
    ClockPopup {
        id: clockPopup
        targetModule: clockModule
    }
}
