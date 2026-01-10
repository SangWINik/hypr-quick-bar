import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real used: 0
    property real total: 0
    property real percent: 0
    property var history: []
    property int maxHistoryLength: 60

    property bool active: false

    onActiveChanged: {
        if (!active) {
            history = []
        }
    }

    property var process: Process {
        command: ["sh", "-c", "free -m | awk 'NR==2 {printf \"%d %d\\n\", $3, $2}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(' ')
                var usedMB = parseFloat(parts[0]) || 0
                var totalMB = parseFloat(parts[1]) || 0
                used = usedMB / 1024.0
                total = totalMB / 1024.0
                percent = totalMB > 0 ? (usedMB / totalMB * 100) : 0
                
                if (active) {
                    var newHistory = history.slice()
                    newHistory.push(percent)
                    if (newHistory.length > maxHistoryLength) {
                        newHistory.shift()
                    }
                    history = newHistory
                }
            }
        }
    }

    function update() {
        process.running = true
    }
}
