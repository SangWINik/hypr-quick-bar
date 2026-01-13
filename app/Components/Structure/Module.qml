import QtQuick

StyledRectangle {
    id: root
    stylePath: ["bar", "section", "module"] 

    // Implicit width calculation using inherited paddingX
    implicitWidth: contentItem.childrenRect.width + horizontalPadding * 2
    
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
        
        // Hover color logic specific to Module
        color: moduleMouseArea.containsMouse ? config.getStyle(stylePath, "hoverColor") : "transparent"
        
        // Reuse radius from root
        radius: root.radius
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
