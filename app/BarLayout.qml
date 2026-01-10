import Quickshell.Services.SystemTray
import QtQuick
import "Components/Clock"
import "Components/Workspaces"
import "Components/Language"
import "Components/Volume"
import "Components/Internet"
import "Components/Power"
import "Components/SystemResources"
import "Components/SystemTray"
import "Components/Media"
import "Components/Structure"

Rectangle {
    id: barLayout
    anchors.fill: parent

    
    // Configuration
    color: config?.bar?.backgroundColor ?? "transparent"
    property string barPosition: "bottom"  // "bottom" or "top"

    // Left section
    BarSection {
        id: timeSection
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Clock {
        }
        
        Calendar {
        }
    }

    // Left section - Media
    BarSection {
        anchors.left: timeSection.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        visible: mediaService.hasActiveMedia

        Media {
            showControlsWhenPaused: false
        }
    }

    // Center section
    BarSection {
        anchors.centerIn: parent

        Workspaces {
        }
    }

    // Right section
    BarSection {
        id: languageSection
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        SystemResources {
        }

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
        }
    }
}
