import QtQuick
import "../Structure"

Module {
    id: calendarModule
    width: 100
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(calendarPopup)
    
    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(timeService.currentTime, "ddd, d MMM")
        color: appTheme.colors.fg
        font.pixelSize: appConfig.fontSize
    }
    
    CalendarPopup {
        id: calendarPopup
        targetModule: calendarModule
    }
}
