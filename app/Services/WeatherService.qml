import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: weatherService
    
    property string temperature: "?"
    property int weatherCode: -1
    property string locationName: ""
    property var forecast: []
    
    // Internal state
    property double latitude: 0.0
    property double longitude: 0.0
    property bool hasCoordinates: false
    
    property int refreshInterval: config.getConfig(["weather"], "refreshIntervalMinutes", 30)
    
    // Timer to trigger refresh
    property var refreshTimer: Timer {
        interval: weatherService.refreshInterval * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: false
        onTriggered: weatherService.refresh()
    }
    
    // Step 1: Location via IP
    property var locationProcess: Process {
        running: false
        command: ["sh", "-c", "curl -s https://ipinfo.io/json"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var json = JSON.parse(this.text);
                    if (json.loc) {
                        var parts = json.loc.split(',');
                        if (parts.length === 2) {
                            weatherService.latitude = parseFloat(parts[0]);
                            weatherService.longitude = parseFloat(parts[1]);
                            weatherService.hasCoordinates = true;
                            
                            // Set location name from city/region
                            var locName = [];
                            if (json.city) locName.push(json.city);
                            if (json.country) locName.push(json.country);
                            weatherService.locationName = locName.join(", ");
                            
                            // Now fetch weather
                            weatherService.weatherProcess.running = true;
                        }
                    }
                } catch (e) {
                    console.error("WeatherService: Error parsing location response: " + e);
                }
            }
        }
    }
    
    // Step 2: Weather Data
    property var weatherProcess: Process {
        running: false
        command: ["sh", "-c", "curl -s \"https://api.open-meteo.com/v1/forecast?latitude=" + weatherService.latitude + "&longitude=" + weatherService.longitude + "&current=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto\""]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var json = JSON.parse(this.text);
                    if (json.current) {
                        weatherService.temperature = Math.round(json.current.temperature_2m) + json.current_units.temperature_2m;
                        weatherService.weatherCode = json.current.weather_code;
                    }
                    
                    if (json.daily) {
                        var newForecast = [];
                        var daily = json.daily;
                        // Iterate through days (typically 7)
                        for (var i = 0; i < daily.time.length; i++) {
                            // Parse date to get day name
                            var date = new Date(daily.time[i]);
                            var dayName = date.toLocaleDateString(Qt.locale(), "ddd");
                            
                            newForecast.push({
                                day: dayName,
                                code: daily.weather_code[i],
                                max: Math.round(daily.temperature_2m_max[i]) + json.daily_units.temperature_2m_max,
                                min: Math.round(daily.temperature_2m_min[i]) + json.daily_units.temperature_2m_min
                            });
                        }
                        weatherService.forecast = newForecast;
                    }
                } catch (e) {
                     console.error("WeatherService: Error parsing weather response: " + e);
                }
            }
        }
    }
    
    function getWeatherIcon(code) {
        if (code === -1) return "󰖪"; 
        
        if (code === 0) return "󰖙"; // Clear
        if (code >= 1 && code <= 3) return "󰖕"; // Cloudy
        if (code === 45 || code === 48) return "󰖑"; // Fog
        if (code >= 51 && code <= 55) return "󰖗"; // Drizzle
        if (code >= 56 && code <= 57) return "󰖘"; // Freezing Drizzle
        if (code >= 61 && code <= 65) return "󰖗"; // Rain
        if (code >= 66 && code <= 67) return "󰖘"; // Freezing Rain
        if (code >= 71 && code <= 77) return "󰼶"; // Snow
        if (code >= 80 && code <= 82) return "󰖖"; // Rain showers
        if (code >= 85 && code <= 86) return "󰼶"; // Snow showers
        if (code >= 95 && code <= 99) return "󰖓"; // Thunderstorm
        
        return "󰖪";
    }
    
    function refresh() {
        locationProcess.running = true;
    }
    
    Component.onCompleted: {
        // Initial fetch after a short delay to ensure config is loaded
        initialTimer.start()
    }
    
    property var initialTimer: Timer {
        interval: 1000
        repeat: false
        onTriggered: weatherService.refresh()
    }
}
