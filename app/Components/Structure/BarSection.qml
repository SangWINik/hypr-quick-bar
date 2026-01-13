import QtQuick


StyledRectangle {
    stylePath: ["bar", "section"]
    
    // Additional property specific to BarSection
    property int sectionSpacing: config.getStyle(stylePath, "spacing")

    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    
    // Only render if there are children
    visible: contentRow.children.length > 0
    
    antialiasing: true
    
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

