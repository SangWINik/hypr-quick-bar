//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick

// import generated theme
import "./Style.qml"
import "Components/Clock"
import "Components/Workspaces"
import "Components/Language"
import "Components/Volume"
import "Components/Internet"
import "Components/Power"
import "Components/SystemTray"
import "Components/Structure"
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
            anchors { bottom: true; left: true; right: true }
            implicitHeight: 40
            color: "transparent"

            // resolved lazily, may be null initially
            property var hyprMonitor: Hyprland.monitorFor(screen)

            Connections {
                target: Hyprland
                function onMonitorsChanged() {
                    console.log("Monitors changed, updating panel monitor assignment");
                    panel.hyprMonitor = Hyprland.monitorFor(screen)
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
            

                // Left section
                BarSection {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8

                    Clock {
                    }
                    
                    Calendar {
                    }
                }

                // Center section
                BarSection {
                    anchors.centerIn: parent

                    Workspaces {
                        hyprMonitor: panel.hyprMonitor
                    }
                }

                // Right section
                BarSection {
                    id: languageSection
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 8

                    Internet {
                    }

                    Volume {
                    }
                    
                    Language {
                    }
                    
                    Power {
                    }
                }

                // Right section - System tray
                BarSection {
                    anchors.right: languageSection.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: SystemTray.items.values.length > 0
                    anchors.rightMargin: 8

                    SystemTray {
                        panelWindow: panel
                    }
                }
            }
        }
    }
}

