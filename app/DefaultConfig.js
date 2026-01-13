.pragma library

var data = {
    "style": {
        "bar": {
            // Global Defaults (Old-fashioned, muted look)
            "backgroundColor": "#eeeeee", // Light gray background
            "textColor": "#222222",       // Dark text
            "dimColor": "#666666",        // Medium gray for dim text
            "errorColor": "#a04040",      // Muted red
            "accentColor": "#507090",     // Muted slate blue
            "borderColor": "#aaaaaa",     // Visible gray border
            "hoverColor": "#d0d0d0",      // Slightly darker gray for hover
            "borderWidth": 0,
            "radius": 0,                  // Sharp corners
            "fontSize": 14,
            "position": "bottom",
            "height": 32,
            "paddingX": 0,

            "section": {
                // Inherits most from bar
                "paddingX": 0,
                "spacing": 0,
                "height": 32,
                "backgroundColor": "transparent",
                "borderWidth": 0,

                "module": {
                    "paddingX": 8,
                    "height": 24,
                    "backgroundColor": "transparent",
                    "hoverColor": "#d0d0d0", // Explicit hover

                    "components": {
                        "workspaces": {
                            "focusedColor": "#507090",      // Accent
                            "hoveredColor": "#d0d0d0",
                            "notificationColor": "#a04040",
                            "defaultColor": "#888888",      // Gray for inactive
                            "focusedTextColor": "#ffffff",  // White text on accent
                            "defaultTextColor": "#222222",
                            "focusedScale": 1.0,            // No scaling (sharp/flat look)
                            "hoveredScale": 1.0
                        },
                        "media": {
                            "separatorColor": "#222222"
                        },
                        "power": {
                            "textColor": "#a04040" // Red for power
                        },
                        "tray": {
                            "iconSize": 16
                        }
                    }
                }
            },
            "margins": {
                "top": 0,
                "bottom": 0,
                "left": 0,
                "right": 0
            },
            "popup": {
                "backgroundColor": "#eeeeee",
                "borderColor": "#888888",
                "borderWidth": 1,
                "radius": 0,

                // Specific overrides
                "power": {
                    "hoverColor": "#a04040", // Red hover for power actions
                    "textColor": "#222222",
                    "warningColor": "#d0a040"
                }
            }
        }
    },
    "components": {
        "weather": {
            "refreshIntervalMinutes": 30,
            "location": "auto"
        },
        "clock": {
            "format": "HH:mm"
        }
    }
}
