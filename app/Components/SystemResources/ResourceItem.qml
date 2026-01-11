import QtQuick

Rectangle {
    id: root
    // Style path - generic for resource items
    property var stylePath: ["bar", "popup", "item"]

    height: 85
    color: "transparent"
    radius: config.getStyle(stylePath, "radius", 12)

    property string title: ""
    property string subtitle: ""
    property string value: ""
    property string temperature: ""
    property var history: []
    property color itemColor: "#5b9cf5"
    property bool showGraph: true

    // Background with subtle color
    Rectangle {
        anchors.fill: parent
        color: root.itemColor
        opacity: 0.08
        radius: parent.radius
    }

    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // Graph
        Rectangle {
            width: 80
            height: parent.height
            color: "transparent"
            radius: 0
            border.color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.3)
            border.width: 1

            Canvas {
                id: graph
                anchors.fill: parent
                visible: root.showGraph

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    if (!root.history || root.history.length === 0) return

                    // Fill area
                    ctx.fillStyle = root.itemColor
                    ctx.globalAlpha = 0.3
                    ctx.beginPath()
                    
                    var maxValue = 100
                    var step = width / Math.max(1, root.history.length - 1)

                    ctx.moveTo(0, height)
                    for (var i = 0; i < root.history.length; i++) {
                        var x = i * step
                        var y = height - (root.history[i] / maxValue * height)
                        ctx.lineTo(x, y)
                    }
                    ctx.lineTo((root.history.length - 1) * step, height)
                    ctx.closePath()
                    ctx.fill()

                    // Stroke line
                    ctx.globalAlpha = 1.0
                    ctx.strokeStyle = root.itemColor
                    ctx.lineWidth = 2
                    ctx.beginPath()

                    for (var j = 0; j < root.history.length; j++) {
                        var x2 = j * step
                        var y2 = height - (root.history[j] / maxValue * height)
                        
                        if (j === 0) {
                            ctx.moveTo(x2, y2)
                        } else {
                            ctx.lineTo(x2, y2)
                        }
                    }

                    ctx.stroke()
                }

                Connections {
                    target: root
                    function onHistoryChanged() {
                        graph.requestPaint()
                    }
                }
            }

            // Placeholder when no graph
            Rectangle {
                anchors.fill: parent
                visible: !root.showGraph
                color: root.itemColor
                opacity: 0.3
            }
        }

        // Info
        Column {
            width: parent.width - 90
            height: parent.height
            spacing: 2

            Text {
                text: root.title
                color: config.getStyle(root.stylePath, "textColor", "#cdd6f4")
                font.pixelSize: 13
                font.weight: Font.Bold
            }

            Text {
                text: root.subtitle
                color: config.getStyle(root.stylePath, "textColorDim", "#bac2de")
                font.pixelSize: 11
                elide: Text.ElideRight
                width: parent.width
            }

            Row {
                spacing: 8

                Text {
                    text: root.value
                    color: config.getStyle(root.stylePath, "textColor", "#cdd6f4")
                    font.pixelSize: 12
                }

                Text {
                    text: root.temperature
                    color: config.getStyle(root.stylePath, "textColorDim", "#bac2de")
                    font.pixelSize: 12
                    visible: root.temperature !== ""
                }
            }
        }
    }
}
