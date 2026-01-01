import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real usage: 0
    property real temp: 0
    property string name: ""
    property var history: []
    property int maxHistoryLength: 60

    property bool active: false

    Component.onCompleted: {
        nameProcess.running = true
    }

    onActiveChanged: {
        if (!active) {
            history = []
        }
    }

    property var nameProcess: Process {
        command: ["sh", "-c", "lscpu | grep 'Model name' | awk -F': ' '{print $2}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                name = this.text.trim()
            }
        }
    }

    property var usageProcess: Process {
        command: ["sh", "-c", "top -bn2 -d 0.5 | grep 'Cpu(s)' | tail -1 | awk '{print 100 - $8}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                usage = parseFloat(this.text.trim()) || 0
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

    property var tempProcess: Process {
        command: ["sh", "-c", "sensors | grep -iE '(Tctl|Tdie|Package id 0|Core 0):' | head -1 | awk '{print $2}' | sed 's/+//;s/°C//'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                temp = parseFloat(this.text.trim()) || 0
            }
        }
    }

    function update() {
        usageProcess.running = true
        tempProcess.running = true
    }
}
