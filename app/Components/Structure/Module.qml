import QtQuick

Rectangle {
    id: root
    
    // radius: 30
    
    property var stylePath: ["bar", "section", "module"] 

    // Padding for content
    property int horizontalPadding: config.getStyle(stylePath, "padding", 12)
    property int verticalPadding: 2
    
    // Module click handler
    signal clicked()
    property bool enableClickArea: false
    property bool enableHover: false
    
    default property alias data: contentItem.data
    
    height: config.getStyle(stylePath, "height", 22)
    color: config.getStyle(stylePath, "backgroundColor", "transparent")
    implicitWidth: contentItem.childrenRect.width + horizontalPadding * 2
    
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
