import QtQuick
import "./SystemResources"

Item {
    id: root

    property int historyDurationSeconds: 60
    property bool monitoringActive: false

    CpuService {
        id: cpu
        maxHistoryLength: historyDurationSeconds
        active: monitoringActive
    }

    MemoryService {
        id: memory
        maxHistoryLength: historyDurationSeconds
        active: monitoringActive
    }

    DiskService {
        id: disk
        maxHistoryLength: historyDurationSeconds
        active: monitoringActive
    }

    NetworkService {
        id: network
        maxHistoryLength: historyDurationSeconds
        active: monitoringActive
    }

    GpuService {
        id: gpu
        maxHistoryLength: historyDurationSeconds
        active: monitoringActive
    }

    Timer {
        id: updateTimer
        interval: 1000
        triggeredOnStart: true
        running: monitoringActive
        repeat: true
        onTriggered: {
            cpu.update()
            memory.update()
            disk.update()
            network.update()
            gpu.update()
        }
    }

    // Expose CPU properties
    readonly property real cpuUsage: cpu.usage
    readonly property real cpuTemp: cpu.temp
    readonly property string cpuName: cpu.name
    readonly property var cpuHistory: cpu.history

    // Expose Memory properties
    readonly property real memoryUsed: memory.used
    readonly property real memoryTotal: memory.total
    readonly property real memoryPercent: memory.percent
    readonly property var memoryHistory: memory.history

    // Expose Disk properties
    readonly property real diskReadSpeed: disk.readSpeed
    readonly property real diskWriteSpeed: disk.writeSpeed
    readonly property real diskUtilization: disk.utilization
    readonly property real diskTemp: disk.temp
    readonly property string diskName: disk.name
    readonly property string diskDevice: disk.device
    readonly property var diskHistory: disk.history

    // Expose Network properties
    readonly property string wiredInterface: network.wiredInterface
    readonly property string wirelessInterface: network.wirelessInterface
    readonly property bool wiredConnected: network.wiredConnected
    readonly property bool wirelessEnabled: network.wirelessEnabled
    readonly property real wiredSendSpeed: network.wiredSendSpeed
    readonly property real wiredRecvSpeed: network.wiredRecvSpeed
    readonly property real wirelessSendSpeed: network.wirelessSendSpeed
    readonly property real wirelessRecvSpeed: network.wirelessRecvSpeed
    readonly property var wiredHistory: network.wiredHistory
    readonly property var wirelessHistory: network.wirelessHistory

    // Expose GPU properties
    readonly property bool hasNvidia: gpu.hasNvidia
    readonly property real gpuUsage: gpu.usage
    readonly property real gpuTemp: gpu.temp
    readonly property string gpuName: gpu.name
    readonly property var gpuHistory: gpu.history

    // Utility function
    function formatBytes(bytes) {
        return network.formatBytes(bytes)
    }

    function resetHistory() {
        cpu.history = []
        memory.history = []
        disk.history = []
        network.wiredHistory = []
        network.wirelessHistory = []
        gpu.history = []
    }
}
