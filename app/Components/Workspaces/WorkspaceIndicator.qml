import Quickshell.Hyprland
import QtQuick

Rectangle {
    required property var workspace
    
    // Receive style path from parent
    property var stylePath

    // State flags
    property bool isFocused: workspace.focused
    property bool isHovered: mouseArea.containsMouse
    property bool hasNotification: false
    
    // Style properties for each state
    property color focusedColor: config.getStyle(stylePath, "focusedColor")
    property color hoveredColor: config.getStyle(stylePath, "hoveredColor")
    property color notificationColor: config.getStyle(stylePath, "notificationColor")
    property color defaultColor: config.getStyle(stylePath, "defaultColor")
    
    property color focusedTextColor: config.getStyle(stylePath, "focusedTextColor")
    property color defaultTextColor: config.getStyle(stylePath, "defaultTextColor")
    
    property real focusedScale: config.getStyle(stylePath, "focusedScale")
    property real hoveredScale: config.getStyle(stylePath, "hoveredScale")
    property real defaultScale: 1.0
    
    width: 18
    height: 18
    radius: width / 2
    
    // Compute color based on state priority
    color: isFocused ? focusedColor
        : hasNotification ? notificationColor
        : isHovered ? hoveredColor
        : defaultColor

    // Compute scale based on state
    scale: isFocused ? focusedScale
        : isHovered ? hoveredScale
        : defaultScale

    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Text {
        anchors.centerIn: parent
        text: workspace.id
        color: isFocused ? focusedTextColor : defaultTextColor
        font.pixelSize: 12
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Hyprland.dispatch("workspace " + workspace.id)
    }
}
