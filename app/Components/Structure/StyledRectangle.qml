import QtQuick

Rectangle {
    id: root
    property var stylePath: []
    
    // Style properties - assuming defaultConfig.json provides valid defaults
    // Using || fallback to handle async config loading delay
    color: config.getStyle(stylePath, "backgroundColor")
    radius: config.getStyle(stylePath, "radius")
    
    border.color: config.getStyle(stylePath, "borderColor")
    border.width: config.getStyle(stylePath, "borderWidth")
    
    property int horizontalPadding: config.getStyle(stylePath, "paddingX")
    
    implicitHeight: config.getStyle(stylePath, "height")
}
