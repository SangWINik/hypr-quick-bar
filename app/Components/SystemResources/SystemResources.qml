import QtQuick
import "../Structure"

Module {
    id: root
    width: 45
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(popup)
    
    Text {
        anchors.centerIn: parent
        text: "󰘚"
        color: appTheme.colors.fg
        font.family: "NotoSansMono Nerd Font"
        font.pixelSize: appConfig.fontSize + 4
    }
    
    SystemResourcesPopup {
        id: popup
        targetModule: root
    }
}
