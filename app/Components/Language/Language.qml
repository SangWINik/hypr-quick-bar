import Quickshell.Hyprland
import Quickshell.Io
import Quickshell
import QtQuick
import "../Structure"

Module {
    id: languageModule
    // Style path
    stylePath: ["bar", "section", "module", "components", "language"]

    width: 45
    
    enableClickArea: false
    enableHover: false
    
    onClicked: popupManager.togglePopup(languagePopup)
    
    property string currentLanguage: "default"
    
    // Listen to Hyprland activelayout events
    Connections {
        target: Hyprland
        
        function onRawEvent(event) {
            // Event format: activelayout>>KEYBOARD_NAME,LAYOUT_NAME
            if (event.name === "activelayout") {
                let parts = event.data.split(",");
                if (parts.length >= 2) {
                    let layoutStr = parts[1].trim();
                    // Remove variant info in parentheses if present
                    let cleanLayout = layoutStr.split("(")[0].trim();
                    currentLanguage = cleanLayout.substring(0, 2).toUpperCase();
                }
            }
        }
    }
    
    // One-shot fetch at startup using stdout collector
    Process {
        id: layoutExec
        running: false
        command: ["sh", "-c", "hyprctl devices 2>/dev/null | grep 'keymap:' | head -1 | awk -F': ' '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim();
                if (out.length >= 2) {
                    languageModule.currentLanguage = out.substring(0, 2).toUpperCase();
                }
            }
        }
    }

    Component.onCompleted: layoutExec.running = true
    
    Text {
        anchors.centerIn: parent
        text: currentLanguage
        color: config.getStyle(languageModule.stylePath, "textColor", "#cdd6f4")
        font.pixelSize: config.getStyle(languageModule.stylePath, "fontSize", 14)
        font.bold: true
    }
    
    LanguagePopup {
        id: languagePopup
        targetModule: languageModule
        currentLanguage: languageModule.currentLanguage
    }
}
