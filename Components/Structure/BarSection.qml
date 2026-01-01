import QtQuick

Rectangle {
    // Theme accessed via appTheme id from root
    
    // Configurable styling
    property color backgroundColor: appTheme.colors.bg
    property color borderColor: appTheme.colors.fg
    property int borderWidth: 1
    property int cornerRadius: 20
    
    // Padding for content
    property int horizontalPadding: 8
    property int verticalPadding: 4
    property int sectionSpacing: 0
    
    color: backgroundColor
    border.color: borderColor
    border.width: borderWidth
    radius: cornerRadius
    antialiasing: true
    
    // Only render if there are children
    visible: contentRow.children.length > 0
    
    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    implicitHeight: contentRow.implicitHeight + verticalPadding * 2
    
    // Default property: children declared in BarSection go into contentRow
    default property alias children: contentRow.children
    
    Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: horizontalPadding
        anchors.rightMargin: horizontalPadding
        anchors.topMargin: verticalPadding
        anchors.bottomMargin: verticalPadding
        spacing: sectionSpacing
        
        // Children (modules) will be added here
    }
}
