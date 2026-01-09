import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    property var bar: ({})
    
    readonly property string configPath: Qt.resolvedUrl("config.json").toString().replace("file://", "")
    
    function loadConfig() {
        configReader.running = false
        configReader.running = true
    }
    
    Component.onCompleted: loadConfig()
    
    property var configReader: Process {
        command: ["cat", configPath]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: root.bar = JSON.parse(this.text).bar
        }
    }
    
    property var fileWatcher: Process {
        running: true
        command: ["sh", "-c", 
            "while inotifywait -q -e modify,close_write " + configPath + " 2>/dev/null; do echo RELOAD; done"
        ]
        
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("RELOAD")) loadConfig()
            }
        }
    }
}