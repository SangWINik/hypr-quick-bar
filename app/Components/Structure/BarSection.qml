import QtQuick

Rectangle {
    // Theme accessed via appTheme id from root
    
    // Configurable styling
    // Configurable styling
    property var stylePath: ["bar", "section"]
    
    property int cornerRadius: config.getStyle(stylePath, "radius", 0)
    
    // Padding for content
    property int horizontalPadding: config.getStyle(stylePath, "padding", 0)
    property int verticalPadding: 20
    property int sectionSpacing: config.getStyle(stylePath, "spacing", 0)
    
    color: config.getStyle(stylePath, "backgroundColor", "transparent")
    border.color: config.getStyle(stylePath, "borderColor", "transparent")
    border.width: config.getStyle(stylePath, "borderWidth", 0)
    radius: config.getStyle(stylePath, "radius", 0)
    antialiasing: true
    
    // Only render if there are children
    visible: contentRow.children.length > 0
    
    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    implicitHeight: config.getStyle(stylePath, "height", 30)
    
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
        anchors.topMargin: verticalPadding
        anchors.bottomMargin: verticalPadding
        anchors.leftMargin: horizontalPadding
        anchors.rightMargin: horizontalPadding
        spacing: config.getStyle(stylePath, "spacing", 0)
        
        // Children (modules) will be added here
    }
}
