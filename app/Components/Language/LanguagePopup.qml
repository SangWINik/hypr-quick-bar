import QtQuick
import "../Structure"

ModulePopup {
    id: languagePopup
    
    property string currentLanguage: "default"
    
    popupHeight: 150
    
    Column {
        anchors.centerIn: parent
        spacing: 10
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Current Layout"
            color: "#888888"
            font.pixelSize: 12
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: languagePopup.currentLanguage
            color: "white"
            font.pixelSize: 32
            font.bold: true
        }
    }
}
