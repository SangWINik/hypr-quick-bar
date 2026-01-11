import QtQuick
import "../Structure"

Module {
    id: powerModule
    // Style path
    stylePath: ["bar", "section", "module", "components", "power"]
    
    width: 45
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(powerPopup)
    
    Text {
        anchors.centerIn: parent
        text: "⏻"
        color: config.getStyle(powerModule.stylePath, "textColor", "#f38ba8")
        font.family: "NotoSansMono Nerd Font"
        font.pixelSize: config.getStyle(powerModule.stylePath, "fontSize", 14) + 8
    }
    
    PowerPopup {
        id: powerPopup
        targetModule: powerModule
    }
}
