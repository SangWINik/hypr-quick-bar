import Quickshell.Hyprland
import QtQuick
import "../Structure"

Module {
    id: workspacesModule
    required property var hyprMonitor
    color: "transparent"

    Row {
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
                
                sourceComponent: WorkspaceIndicator {
                    workspace: modelData
                }
            }
        }
    }
}
