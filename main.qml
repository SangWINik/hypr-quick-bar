//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import QtQuick

// import generated theme
import "./Style.qml"
import "Services"

Scope {
    id: root
    
    Style {
        id: appTheme
    }
    
    QtObject {
        id: config
        property int fontSize: 14
        property int moduleHeight: 22
    }
    
    TimeService {
        id: timeService
    }
    
    InternetService {
        id: internetService
    }
    
    SystemResourcesService {
        id: systemResourcesService
    }
    
    MediaService {
        id: mediaService
    }
    
    PopupManager {
        id: popupManager
    }

    Component.onCompleted: {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            property var hyprMonitor: Hyprland.monitorFor(screen)
            
            anchors {
                bottom: barLayout.barPosition === "bottom"
                top: barLayout.barPosition !== "bottom"
                left: true
                right: true
            }
            implicitHeight: 40
            color: "transparent"

            BarLayout {
                id: barLayout
            }
        }
    }
}

