import QtQuick
import "../Structure"

Module {
    id: powerModule
    width: 45
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(powerPopup)
    
    Text {
        anchors.centerIn: parent
        text: "⏻"
        color: appTheme.colors.error
        font.family: "NotoSansMono Nerd Font"
        font.pixelSize: appConfig.fontSize + 8
    }
    
    PowerPopup {
        id: powerPopup
        targetModule: powerModule
    }
}
