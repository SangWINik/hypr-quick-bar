//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import QtQuick

// import generated theme
import "./Style.qml"
import "./Config.qml"
import "Services"

Scope {
    id: root
    
    Style {
        id: appTheme
    }
    
    Config {
        id: config
    }
    
    QtObject {
        id: appConfig
        property int fontSize: 14
        property int moduleHeight: appConfig.bar.module?.height ?? 22
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
            
            margins {
                top: config.bar?.margins?.top ?? 8
                bottom: config.bar?.margins?.bottom ?? 8
                left: config.bar?.margins?.left ?? 8
                right: config.bar?.margins?.right ?? 8
            }
            implicitHeight: config.bar?.height ?? 32
            color: "transparent"

            BarLayout {
                id: barLayout
            }
        }
    }
}

