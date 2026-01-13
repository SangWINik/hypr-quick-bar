import QtQuick

Rectangle {
    property var stylePath: ["bar", "section"]
    
    property int horizontalPadding: config.getStyle(stylePath, "paddingX", 0)
    property int sectionSpacing: config.getStyle(stylePath, "spacing", 0)

    implicitHeight: config.getStyle(stylePath, "height", 30)
    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    
    color: config.getStyle(stylePath, "backgroundColor", "transparent")
    radius: config.getStyle(stylePath, "radius", 0)
    border.color: config.getStyle(stylePath, "borderColor", "transparent")
    border.width: config.getStyle(stylePath, "borderWidth", 0)
    
    antialiasing: true
    
    // Only render if there are children
    visible: contentRow.children.length > 0
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }
    
    // Default property: children declared in BarSection go into contentRow
    default property alias children: contentRow.children
    
    Row {
        id: contentRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: horizontalPadding
        anchors.rightMargin: horizontalPadding
        spacing: sectionSpacing
        
        // Children (modules) will be added here
    }
}
