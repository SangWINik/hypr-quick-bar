import Quickshell.Hyprland
import QtQuick

Rectangle {
    required property var workspace
    
    // State flags
    property bool isFocused: workspace.focused
    property bool isHovered: mouseArea.containsMouse
    property bool hasNotification: false
    
    // Style properties for each state
    property color focusedColor: appTheme.colors.accent
    property color hoveredColor: appTheme.colors.fg_a60
    property color notificationColor: appTheme.colors.warning
    property color defaultColor: appTheme.colors.fg
    
    property color focusedTextColor: appTheme.colors.bg
    property color defaultTextColor: appTheme.colors.bg
    
    property real focusedScale: 1.3
    property real hoveredScale: 1.08
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
