import Quickshell.Hyprland
import QtQuick
import "../Structure"

Module {
    id: workspacesModule
    required property var hyprMonitor
    color: "transparent"

    Row {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Hyprland.workspaces

            delegate: Loader {
                active: modelData.id >= 0
                    && workspacesModule.hyprMonitor !== null
                    && modelData.monitor !== null
                    && modelData.monitor !== undefined
                    && modelData.monitor.name === workspacesModule.hyprMonitor.name
                
                visible: active // without this line there are issues on disconnecting/reconnecting monitors, makes sure there are no invisible items taking space
                scale: active ? 1 : 0
                opacity: active ? 1 : 0
                
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                
                sourceComponent: WorkspaceIndicator {
                    workspace: modelData
                }
            }
        }
    }
}
