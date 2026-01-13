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
        color: config.getStyle(clockModule.stylePath, "textColor")
        font.pixelSize: config.getStyle(clockModule.stylePath, "fontSize")
        text: Qt.formatDateTime(timeService.currentTime, config.getComponentConfig("clock", "format"))
    }
    
    ClockPopup {
        id: clockPopup
        targetModule: clockModule
    }
}
