import QtQuick

Rectangle {
    id: root
    property var stylePath: ["bar", "section", "module"] 

    // Padding for content
    property int horizontalPadding: config.getStyle(stylePath, "paddingX", 12)

    implicitHeight: config.getStyle(stylePath, "height", 22)
    implicitWidth: contentItem.childrenRect.width + horizontalPadding * 2
    color: config.getStyle(stylePath, "backgroundColor", "transparent")
    
    // Module click handler
    signal clicked()
    property bool enableClickArea: false
    property bool enableHover: false
    
    default property alias data: contentItem.data

    
    MouseArea {
        id: moduleMouseArea
        anchors.fill: parent
        enabled: root.enableClickArea
        hoverEnabled: root.enableHover
        onClicked: root.clicked()
        z: 1
    }
    
    Rectangle {
        anchors.fill: parent
        
        color: moduleMouseArea.containsMouse ? config.getStyle(stylePath, "hoverColor", "#4dcdd6f4") : "transparent"
        radius: config.getStyle(stylePath, "radius", 6)
        z: 0
        visible: root.enableHover
        
        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
    
    Item {
        id: contentItem
        anchors.centerIn: parent
        z: 2
    }
}
