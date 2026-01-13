import QtQuick
import "../Structure"

Module {
    id: calendarModule
    // Style path
    stylePath: ["bar", "section", "module", "components", "calendar"]
    
    width: 100
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(calendarPopup)
    
    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(timeService.currentTime, "ddd, d MMM")
        color: config.getStyle(calendarModule.stylePath, "textColor")
        font.pixelSize: config.getStyle(calendarModule.stylePath, "fontSize")
    }
    
    CalendarPopup {
        id: calendarPopup
        targetModule: calendarModule
    }
}
