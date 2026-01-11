import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    property var bar: ({})
    
    readonly property string configPath: {
        var envPath = Quickshell.env("CONFIG_FILE");
        if (envPath && envPath.length > 0)
            return envPath;
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
            onStreamFinished: {
                var json = JSON.parse(this.text)
                root.style = json.style || {}
            }
        }
    }

    property var style: ({})

    // Recursive style lookup
    // path: array of strings, e.g. ["bar", "section", "module", "components", "clock"]
    // property: string, e.g. "color"
    // defaultValue: any
    function getStyle(path, property, defaultValue) {
        if (!path || !Array.isArray(path)) return defaultValue;
        if (!root.style || !root.style.bar) return defaultValue;
        
        var candidates = [];
        
        var resolve = function(obj, pathArr) {
            if (!obj || !pathArr) return null;
            var curr = obj;
            for (var i = 0; i < pathArr.length; i++) {
                if (!curr) return null;
                curr = curr[pathArr[i]];
            }
            return curr;
        }

        var obj = resolve(root.style, path);
        if (obj && obj[property] !== undefined) return obj[property];
        
        var workingPath = path.slice();
        while (workingPath.length > 0) {
            // Remove last segment
             var segment = workingPath.pop();
             
             // If we just popped a specific name (like 'clock'), we might check if previous was 'components'
             if (workingPath.length > 0 && workingPath[workingPath.length-1] === 'components') {
                 workingPath.pop(); // Remove 'components' to get to 'module'
             }
             
             // Now check property on this level
             obj = resolve(root.style, workingPath);
             if (obj && obj[property] !== undefined) return obj[property];
        }
        
        return defaultValue;
    }
}