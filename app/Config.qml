import QtQuick
import Quickshell
import Quickshell.Io
import "DefaultConfig.js" as Default

Scope {
    id: root
    
    // Properties to hold config data
    // Initialize defaultStyle directly from the JS file (Synchronous!)
    property var defaultStyle: Default.data.style || {}
    property var defaultComponents: Default.data.components || {}
    
    property var style: ({})
    property var components: ({})
    
    // Config path construction
    readonly property string systemConfigPath: {
        var envPath = Quickshell.env("CONFIG_FILE");
        if (envPath && envPath.length > 0)
            return envPath;
        var cacheHome = Quickshell.env("XDG_CACHE_HOME");
        var home = Quickshell.env("HOME");
        var basePath = cacheHome || (home + "/.cache");
        return basePath + "/hypr-quick-bar/config.json";
    }

    function loadConfig() {
        // Trigger user config loading
        userConfigReader.running = false
        userConfigReader.running = true
    }
    
    Component.onCompleted: loadConfig()

    // Async process to read User config
    property var userConfigReader: Process {
        command: ["cat", systemConfigPath]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var json = JSON.parse(this.text)
                    root.style = json.style || {}
                    root.components = json.components || {}
                } catch (e) {
                    console.warn("Failed to parse user config.json or file empty:", e)
                }
            }
        }
    }

    // Helper to resolve path in an object
    function resolvePath(obj, pathArr) {
        if (!obj || !pathArr) return null;
        var curr = obj;
        for (var i = 0; i < pathArr.length; i++) {
            if (!curr) return null;
            curr = curr[pathArr[i]];
        }
        return curr;
    }

    // Recursive style lookup
    function getStyle(path, property) {
        if (!path || !Array.isArray(path)) return undefined;
        
        // 1. Check User Config (Exact Path)
        var obj = resolvePath(root.style, path);
        if (obj && obj[property] !== undefined) return obj[property];
        
        // 2. Check User Config (Recursive Fallback)
        var workingPath = path.slice();
        while (workingPath.length > 0) {
            var segment = workingPath.pop();
            if (workingPath.length > 0 && workingPath[workingPath.length-1] === 'components') {
                 workingPath.pop(); 
            }
            obj = resolvePath(root.style, workingPath);
            if (obj && obj[property] !== undefined) return obj[property];
        }

        // 3. Check Default Config (Exact Path) - Synchronous!
        obj = resolvePath(root.defaultStyle, path);
        if (obj && obj[property] !== undefined) return obj[property];

        // 4. Check Default Config (Recursive Fallback) - Synchronous!
        workingPath = path.slice();
        while (workingPath.length > 0) {
            var segment = workingPath.pop();
            if (workingPath.length > 0 && workingPath[workingPath.length-1] === 'components') {
                 workingPath.pop(); 
            }
            obj = resolvePath(root.defaultStyle, workingPath);
            if (obj && obj[property] !== undefined) return obj[property];
        }
        
        return undefined;
    }

    // Generic config lookup for components
    // Explicitly accepts module name (e.g. "clock", "weather") since the config structure is flat
    function getComponentConfig(moduleName, property) {
        if (!moduleName || typeof moduleName !== 'string') return undefined;

        // 1. User Config
        if (root.components && root.components[moduleName] && root.components[moduleName][property] !== undefined)
            return root.components[moduleName][property];
        
        // 2. Default Config
        if (root.defaultComponents && root.defaultComponents[moduleName] && root.defaultComponents[moduleName][property] !== undefined)
            return root.defaultComponents[moduleName][property];
        
        return undefined;
    }
}