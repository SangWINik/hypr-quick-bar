import QtQuick
import "../Structure"

ModulePopup {
    id: popup
    implicitWidth: 360
    implicitHeight: contentColumn.height + 16 + contentColumn.bottomPadding

    onVisibleChanged: {
        systemResourcesService.monitoringActive = visible
        if (visible) {
            systemResourcesService.resetHistory()
        }
    }

    Column {
        id: contentColumn
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 8
        }
        spacing: 6
        bottomPadding: 8

        // CPU
        ResourceItem {
            width: parent.width
            title: "CPU"
            subtitle: systemResourcesService.cpuName
            value: Math.round(systemResourcesService.cpuUsage) + "%"
            temperature: Math.round(systemResourcesService.cpuTemp) + "°C"
            history: systemResourcesService.cpuHistory
            itemColor: "#7095b3" // Muted blue
        }

        // Memory
        ResourceItem {
            width: parent.width
            title: "Memory"
            subtitle: systemResourcesService.memoryUsed.toFixed(1) + " GiB of " + systemResourcesService.memoryTotal.toFixed(1) + " GiB"
            value: Math.round(systemResourcesService.memoryPercent) + "%"
            history: systemResourcesService.memoryHistory
            itemColor: "#8e8aa3" // Muted purple
        }

        // NVMe
        ResourceItem {
            width: parent.width
            title: systemResourcesService.diskDevice ? systemResourcesService.diskDevice.toUpperCase() : "Disk"
            subtitle: "R: " + systemResourcesService.formatBytes(systemResourcesService.diskReadSpeed) + " W: " + systemResourcesService.formatBytes(systemResourcesService.diskWriteSpeed)
            value: Math.round(systemResourcesService.diskTemp) + "°C"
            temperature: ""
            history: systemResourcesService.diskHistory
            itemColor: "#6fa388" // Muted green
        }

        // Wired Network
        ResourceItem {
            width: parent.width
            title: "Wired (" + systemResourcesService.wiredInterface + ")"
            subtitle: "S: " + systemResourcesService.formatBytes(systemResourcesService.wiredSendSpeed)
            value: "R: " + systemResourcesService.formatBytes(systemResourcesService.wiredRecvSpeed)
            history: systemResourcesService.wiredHistory
            itemColor: "#a3889e" // Muted pink
        }

        // Wireless Network
        ResourceItem {
            width: parent.width
            title: "Wireless (" + systemResourcesService.wirelessInterface + ")"
            subtitle: "S: " + systemResourcesService.formatBytes(systemResourcesService.wirelessSendSpeed)
            value: "R: " + systemResourcesService.formatBytes(systemResourcesService.wirelessRecvSpeed)
            history: systemResourcesService.wirelessHistory
            itemColor: "#a3889e" // Muted pink
        }

        // GPU
        ResourceItem {
            width: parent.width
            visible: systemResourcesService.hasNvidia
            title: "GPU"
            subtitle: systemResourcesService.gpuName
            value: Math.round(systemResourcesService.gpuUsage) + "%"
            temperature: Math.round(systemResourcesService.gpuTemp) + "°C"
            history: systemResourcesService.gpuHistory
            itemColor: "#a38870" // Muted orange
        }
    }
}
