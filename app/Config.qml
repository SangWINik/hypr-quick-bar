import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    property var bar: ({})
    
    readonly property string configPath: {
        var cacheHome = Quickshell.env("XDG_CACHE_HOME");
        var home = Quickshell.env("HOME");
        var basePath = cacheHome || (home + "/.cache");
        return basePath + "/hypr-quick-bar/config.json";
    }
    
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
}