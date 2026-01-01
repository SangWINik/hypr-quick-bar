import QtQuick

Rectangle {
    id: root
    
    // Common module styling
    color: "transparent"
    // radius: 30
    
    // Padding for content
    property int horizontalPadding: 12
    property int verticalPadding: 2
    
    // Module click handler
    signal clicked()
    property bool enableClickArea: false
    property bool enableHover: false
    
    default property alias data: contentItem.data
    
    height: config.moduleHeight
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
        color: moduleMouseArea.containsMouse ? appTheme.colors.fg_a30 : "transparent"
        radius: 6
        z: 0
        visible: root.enableHover
    }
    
    Item {
        id: contentItem
        anchors.centerIn: parent
        z: 2
    }
}
