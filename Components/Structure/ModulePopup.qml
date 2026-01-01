import QtQuick
import Quickshell

PopupWindow {
    id: popup
    
    // The module this popup belongs to
    property var targetModule: null
    
    // Custom content provided by the module
    default property alias content: contentContainer.data
    
    // Popup dimensions
    property int popupWidth: 200
    property int popupHeight: 100
    
    // Offset from module (negative = above for bottom bar)
    property int offset: 0
    
    // Style properties
    property color backgroundColor: appTheme.colors.bg_a80
    property color borderColor: appTheme.colors.fg_a50
    property int borderWidth: 0
    property int cornerRadius: 10
    
    visible: false
    implicitWidth: popupWidth
    implicitHeight: popupHeight
    
    anchor.window: panel
    anchor.rect.x: {
        if (!targetModule) return 0
        
        // Calculate position by walking up the parent chain to panel.contentItem
        var x = 0
        var item = targetModule
        while (item && item !== panel.contentItem) {
            x += item.x
            item = item.parent
        }
        
        // Center popup horizontally under module
        return x + (targetModule.width - width) / 2
    }
    anchor.rect.y: {
        if (!targetModule) return 0
        
        var isPanelAtBottom = panel.anchors.bottom
        
        if (isPanelAtBottom) {
            return -height - offset
        } else {
            return panel.height + offset
        }
    }
    
    color: "transparent"
    
    // Animation properties
    property bool animating: false
    property real animationProgress: visible ? 1.0 : 0.0
    
    Behavior on animationProgress {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: popup.backgroundColor
        border.color: popup.borderColor
        border.width: popup.borderWidth
        radius: popup.cornerRadius
        
        // Opacity animation
        opacity: popup.animationProgress
        
        // Slide animation - slide from panel direction
        transform: Translate {
            y: {
                var isPanelAtBottom = panel.anchors.bottom
                var slideDistance = 100
                
                if (isPanelAtBottom) {
                    return slideDistance * (1 - popup.animationProgress)
                } else {
                    return -slideDistance * (1 - popup.animationProgress)
                }
            }
        }
        
        Item {
            id: contentContainer
            anchors.fill: parent
            anchors.margins: 10
        }
    }
}
