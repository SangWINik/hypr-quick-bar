import QtQuick
import "../Structure"

Module {
    id: root
    // Style path
    stylePath: ["bar", "section", "module", "components", "systemResources"]

    width: 45
    
    enableClickArea: true
    enableHover: true
    
    onClicked: popupManager.togglePopup(popup)
    
    Text {
        anchors.centerIn: parent
        text: "󰘚"
        color: config.getStyle(root.stylePath, "textColor", "#cdd6f4")
        font.family: "NotoSansMono Nerd Font"
        font.pixelSize: config.getStyle(root.stylePath, "fontSize", 14) + 4
    }
    
    SystemResourcesPopup {
        id: popup
        targetModule: root
    }
}
