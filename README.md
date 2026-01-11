# hypr-quick-bar
My implementation of a bar for Hyprland based on quickshell

## Configuration

The bar is configured via `~/.config/hypr-quick-bar/config.json` (or other directory passed as --config-dir arg when starting the application).

### Hierarchical Styling
Styles cascade down from broader scopes to specific components. A property defined at the `module` level applies to all modules unless overridden by a specific component.

**Lookup Order:** `Component` -> `Module` -> `Section` -> `Bar`

### Example `config.json`
```json
{
  "style": {
    "bar": {
      "height": 32,
      "backgroundColor": "transparent",
      "section": {
        "backgroundColor": "#1e1e2e",
        "module": {
          "textColor": "#cdd6f4", // Default for all modules
          "components": {
            "clock": {
              "textColor": "#f38ba8" // Specific override
            }
          }
        }
      }
    }
  }
}
```
See `config.json.example` for a full reference.
