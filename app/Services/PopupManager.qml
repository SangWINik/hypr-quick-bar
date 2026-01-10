import QtQuick

QtObject {
    id: popupManager
    
    property var currentPopup: null
    
    function togglePopup(popup) {
        // If this popup is already open, close it
        if (currentPopup === popup && popup.visible) {
            popup.visible = false
            currentPopup = null
        } else {
            // Close any other open popup
            if (currentPopup && currentPopup !== popup) {
                currentPopup.visible = false
            }
            // Open this popup
            popup.visible = true
            currentPopup = popup
        }
    }
    
    function closeCurrentPopup() {
        if (currentPopup) {
            currentPopup.visible = false
            currentPopup = null
        }
    }
}
