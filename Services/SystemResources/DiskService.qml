import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real readSpeed: 0
    property real writeSpeed: 0
    property real utilization: 0
    property real temp: 0
    property string name: ""
    property string device: ""
    property var history: []
    property int maxHistoryLength: 60

    property bool active: false

    property real prevRead: 0
    property real prevWrite: 0
    property real prevIoTime: 0

    Component.onCompleted: {
        deviceDetector.running = true
    }

    property var deviceDetector: Process {
        command: ["sh", "-c", "lsblk -d -n -o NAME,TYPE | grep disk | head -1 | awk '{print $1}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                device = this.text.trim()
                if (device) {
                    nameProcess.running = true
                }
            }
        }
    }

    onActiveChanged: {
        if (!active) {
            history = []
        }
    }

    property var nameProcess: Process {
        command: ["sh", "-c", "lsblk -d -o NAME,MODEL | grep '" + device + "' | awk '{$1=\"\"; print $0}' | xargs"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                name = this.text.trim()
            }
        }
    }

    property var ioProcess: Process {
        command: ["sh", "-c", "cat /proc/diskstats | grep '" + device + " ' | awk '{print $6, $10, $13}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(' ')
                var readSectors = parseFloat(parts[0]) || 0
                var writeSectors = parseFloat(parts[1]) || 0
                var ioTimeMs = parseFloat(parts[2]) || 0
                
                if (prevRead > 0) {
                    readSpeed = (readSectors - prevRead) * 512
                    writeSpeed = (writeSectors - prevWrite) * 512
                    
                    var ioTimeDelta = ioTimeMs - prevIoTime
                    utilization = Math.min(100, (ioTimeDelta / 10))
                    
                    if (active) {
                        var newHistory = history.slice()
                        newHistory.push(utilization)
                        if (newHistory.length > maxHistoryLength) {
                            newHistory.shift()
                        }
                        history = newHistory
                    }
                }
                
                prevRead = readSectors
                prevWrite = writeSectors
                prevIoTime = ioTimeMs
            }
        }
    }

    property var tempProcess: Process {
        command: ["sh", "-c", "sensors | grep -iE '(" + device + "|Composite)' -A 2 | grep 'Composite:' | awk '{print $2}' | sed 's/+//;s/°C//' | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                temp = parseFloat(this.text.trim()) || 0
            }
        }
    }

    function update() {
        ioProcess.running = true
        tempProcess.running = true
    }
}
