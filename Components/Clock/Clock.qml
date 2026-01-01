import QtQuick
import "../Structure"

Module {
    id: clockModule
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(clockPopup)
    
    Text {
        anchors.centerIn: parent
        color: appTheme.colors.fg
        font.pixelSize: config.fontSize
        text: Qt.formatDateTime(timeService.currentTime, "HH:mm")
    }
    
    ClockPopup {
        id: clockPopup
        targetModule: clockModule
    }
}
