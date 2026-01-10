import QtQuick

Item {
    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: parent.currentTime = new Date()
    }
}
