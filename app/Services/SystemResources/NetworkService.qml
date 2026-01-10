import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string wiredInterface: ""
    property string wirelessInterface: ""
    
    property bool wiredConnected: false
    property bool wirelessEnabled: false
    
    property real wiredSendSpeed: 0
    property real wiredRecvSpeed: 0
    property real wirelessSendSpeed: 0
    property real wirelessRecvSpeed: 0
    
    property var wiredHistory: []
    property var wirelessHistory: []
    property int maxHistoryLength: 60

    property bool active: false

    property real prevWiredSent: 0
    property real prevWiredRecv: 0
    property real prevWirelessSent: 0
    property real prevWirelessRecv: 0

    Component.onCompleted: {
        wiredInterfaceDetector.running = true
        wirelessInterfaceDetector.running = true
    }

    onActiveChanged: {
        if (!active) {
            wiredHistory = []
            wirelessHistory = []
        }
    }

    property var wiredInterfaceDetector: Process {
        command: ["sh", "-c", "ls /sys/class/net/ | grep -v '^lo$' | grep -E '^(en|eth)' | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                wiredInterface = this.text.trim()
            }
        }
    }

    property var wirelessInterfaceDetector: Process {
        command: ["sh", "-c", "ls /sys/class/net/ | grep -E '^(wl|wlan)' | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                wirelessInterface = this.text.trim()
            }
        }
    }

    property var wiredProcess: Process {
        command: ["sh", "-c", "cat /sys/class/net/" + wiredInterface + "/operstate 2>/dev/null; cat /proc/net/dev | grep '" + wiredInterface + "' | awk '{print $2, $10}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (!wiredInterface) return
                var lines = this.text.trim().split('\n')
                if (lines.length < 2) return
                
                wiredConnected = (lines[0] === 'up')
                
                var parts = lines[1].trim().split(' ')
                var recv = parseFloat(parts[0]) || 0
                var sent = parseFloat(parts[1]) || 0
                
                if (prevWiredRecv > 0) {
                    wiredRecvSpeed = recv - prevWiredRecv
                    wiredSendSpeed = sent - prevWiredSent
                    
                    if (active) {
                        var totalSpeed = (wiredRecvSpeed + wiredSendSpeed) / (1024 * 1024)
                        var speedPercent = Math.min(100, totalSpeed * 10)
                        
                        var newHistory = wiredHistory.slice()
                        newHistory.push(speedPercent)
                        if (newHistory.length > maxHistoryLength) {
                            newHistory.shift()
                        }
                        wiredHistory = newHistory
                    }
                }
                
                prevWiredRecv = recv
                prevWiredSent = sent
            }
        }
    }

    property var wirelessProcess: Process {
        command: ["sh", "-c", "cat /sys/class/net/" + wirelessInterface + "/operstate 2>/dev/null; cat /proc/net/dev | grep '" + wirelessInterface + "' | awk '{print $2, $10}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (!wirelessInterface) return
                var lines = this.text.trim().split('\n')
                if (lines.length < 2) return
                
                wirelessEnabled = (lines[0] !== 'down')
                
                var parts = lines[1].trim().split(' ')
                var recv = parseFloat(parts[0]) || 0
                var sent = parseFloat(parts[1]) || 0
                
                if (prevWirelessRecv > 0) {
                    wirelessRecvSpeed = recv - prevWirelessRecv
                    wirelessSendSpeed = sent - prevWirelessSent
                    
                    if (active) {
                        var totalSpeed = (wirelessRecvSpeed + wirelessSendSpeed) / (1024 * 1024)
                        var speedPercent = Math.min(100, totalSpeed * 10)
                        
                        var newHistory = wirelessHistory.slice()
                        newHistory.push(speedPercent)
                        if (newHistory.length > maxHistoryLength) {
                            newHistory.shift()
                        }
                        wirelessHistory = newHistory
                    }
                }
                
                prevWirelessRecv = recv
                prevWirelessSent = sent
            }
        }
    }

    function update() {
        wiredProcess.running = true
        wirelessProcess.running = true
    }

    function formatBytes(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B/s"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(0) + " KiB/s"
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MiB/s"
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GiB/s"
    }
}
