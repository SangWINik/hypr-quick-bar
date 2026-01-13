//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import QtQuick

// import generated theme
// import generated theme
import "./Config.qml"
import "Services"

Scope {
    id: root

    Config {
        id: config
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
    
    WeatherService {
        id: weatherService
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
            
            margins {
                top: config.getStyle(["bar", "margins"], "top")
                bottom: config.getStyle(["bar", "margins"], "bottom")
                left: config.getStyle(["bar", "margins"], "left")
                right: config.getStyle(["bar", "margins"], "right")
            }
            implicitHeight: config.getStyle(["bar"], "height")
            color: "transparent"

            BarLayout {
                id: barLayout
            }
        }
    }
}

