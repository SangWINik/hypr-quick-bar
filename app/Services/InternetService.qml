import Quickshell.Io
import QtQuick

QtObject {
    id: internetService
    
    property bool isConnected: false
    property string connectionType: "unknown" // "wifi", "ethernet", "disconnected"
    property int wifiSignalStrength: 0 // 0-100
    property string wifiSSID: ""
    property string deviceName: ""
    property string ipAddress: ""
    property bool wifiEnabled: true
    property bool wifiToggling: false
    
    // Monitor NetworkManager state via D-Bus monitoring
    property var nmMonitor: Process {
        running: true
        command: ["sh", "-c", "dbus-monitor --system \"type='signal',interface='org.freedesktop.NetworkManager',member='StateChanged'\" 2>/dev/null"]
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: line => {
                if (line.includes("StateChanged")) {
                    statusChecker.running = true
                }
            }
        }
    }
    
    // Monitor for device state changes
    property var deviceMonitor: Process {
        running: true
        command: ["sh", "-c", "dbus-monitor --system \"type='signal',interface='org.freedesktop.NetworkManager.Device',member='StateChanged'\" 2>/dev/null"]
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: line => {
                if (line.includes("StateChanged")) {
                    statusChecker.running = true
                }
            }
        }
    }
    
    // Monitor WiFi signal strength changes
    property var wifiMonitor: Process {
        running: true
        command: ["sh", "-c", "dbus-monitor --system \"type='signal',interface='org.freedesktop.NetworkManager.Device.Wireless',member='PropertiesChanged'\" 2>/dev/null"]
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: line => {
                if (line.includes("PropertiesChanged")) {
                    statusChecker.running = true
                }
            }
        }
    }
    
    // Process to check current network status
    property var statusChecker: Process {
        running: false
        command: ["sh", "-c", "nmcli -t radio wifi; nmcli -t -f STATE general; nmcli -t -f DEVICE,TYPE,STATE device | grep 'connected' | grep -E 'wifi|ethernet' | head -1; nmcli -t -f IN-USE,SIGNAL,SSID device wifi list 2>/dev/null | grep '^\\*' | head -1"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n').filter(l => l.length > 0)
                
                if (lines.length === 0) {
                    isConnected = false
                    connectionType = "disconnected"
                    wifiSignalStrength = 0
                    wifiSSID = ""
                    deviceName = ""
                    ipAddress = ""
                    return
                }
                
                // First line: WiFi radio state
                if (lines[0] === 'enabled' || lines[0] === 'disabled') {
                    wifiEnabled = (lines[0] === 'enabled')
                }
                
                if (lines.length < 2) {
                    isConnected = false
                    connectionType = "disconnected"
                    wifiSignalStrength = 0
                    wifiSSID = ""
                    deviceName = ""
                    ipAddress = ""
                    return
                }
                
                // Second line: general state
                const generalState = lines[1]
                isConnected = generalState.startsWith('connected')
                
                if (!isConnected || lines.length < 3) {
                    connectionType = "disconnected"
                    wifiSignalStrength = 0
                    wifiSSID = ""
                    deviceName = ""
                    ipAddress = ""
                    return
                }
                
                // Third line: device details (DEVICE:TYPE:STATE)
                const deviceInfo = lines[2].split(':')
                if (deviceInfo.length >= 2) {
                    deviceName = deviceInfo[0]
                    const type = deviceInfo[1]
                    connectionType = type
                    
                    // Fourth line (if exists): WiFi signal (*:SIGNAL:SSID)
                    if (type === 'wifi' && lines.length >= 4) {
                        const wifiInfo = lines[3].split(':')
                        if (wifiInfo.length >= 2) {
                            const signal = parseInt(wifiInfo[1])
                            wifiSignalStrength = isNaN(signal) ? 0 : signal
                        }
                        if (wifiInfo.length >= 3) {
                            wifiSSID = wifiInfo[2]
                        }
                    } else {
                        wifiSignalStrength = 0
                        wifiSSID = ""
                    }
                    
                    // Get IP address using ip command
                    ipChecker.running = true
                } else {
                    connectionType = "disconnected"
                    wifiSignalStrength = 0
                    wifiSSID = ""
                    deviceName = ""
                    ipAddress = ""
                }
            }
        }
    }
    
    // Separate process to get IP address
    property var ipChecker: Process {
        running: false
        command: ["sh", "-c", "ip addr show " + deviceName + " 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const ip = this.text.trim()
                ipAddress = ip || ""
            }
        }
    }
    
    Component.onCompleted: statusChecker.running = true
    
    function toggleWifi() {
        if (wifiToggling) return
        wifiToggling = true
        const command = wifiEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on"
        wifiToggleProcess.command = ["sh", "-c", command]
        wifiToggleProcess.running = true
    }
    
    property var wifiToggleProcess: Process {
        running: false
        onExited: {
            // Refresh status after toggling WiFi
            statusChecker.running = true
            wifiToggling = false
        }
    }
    
    function refresh() {
        statusChecker.running = true
    }
}
