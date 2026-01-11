import QtQuick

Rectangle {
    // Theme accessed via appTheme id from root
    
    // Configurable styling
    property color borderColor: appTheme.colors.fg
    property int borderWidth: 1
    property int cornerRadius: 20
    
    // Padding for content
    property int horizontalPadding: 8
    property int verticalPadding: 0
    property int sectionSpacing: 0
    
    color: config.bar?.section?.backgroundColor || "transparent"
    border.color: borderColor
    border.width: borderWidth
    radius: cornerRadius
    antialiasing: true
    
    // Only render if there are children
    visible: contentRow.children.length > 0
    
    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    // implicitHeight: contentRow.implicitHeight + verticalPadding * 2
    implicitHeight: config?.bar?.section?.height ?? 22
    
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
