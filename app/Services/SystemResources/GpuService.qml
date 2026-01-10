import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool hasNvidia: false
    property real usage: 0
    property real temp: 0
    property string name: ""
    property var history: []
    property int maxHistoryLength: 60

    property bool active: false

    Component.onCompleted: {
        detector.running = true
    }

    onActiveChanged: {
        if (!active) {
            history = []
        }
    }

    property var detector: Process {
        command: ["sh", "-c", "command -v nvidia-smi > /dev/null 2>&1 && nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var result = this.text.trim()
                if (result) {
                    hasNvidia = true
                    name = result
                }
            }
        }
    }

    property var statsProcess: Process {
        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(',')
                usage = parseFloat(parts[0]) || 0
                temp = parseFloat(parts[1]) || 0
                
                if (active) {
                    var newHistory = history.slice()
                    newHistory.push(usage)
                    if (newHistory.length > maxHistoryLength) {
                        newHistory.shift()
                    }
                    history = newHistory
                }
            }
        }
    }

    function update() {
        if (hasNvidia) {
            statsProcess.running = true
        }
    }
}
