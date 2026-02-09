pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    // ============================================================================
    // CONFIGURATION & LOCATION
    // ============================================================================

    readonly property real latitude: Settings.config.weather.latitude
    readonly property real longitude: Settings.config.weather.longitude
    readonly property bool enabled: Settings.config.weather.enabled

    // ============================================================================
    // CURRENT WEATHER DATA
    // ============================================================================

    property int currentWeatherCode: 0
    property real currentTemp: 0
    property real windSpeed: 0
    property int humidity: 0
    property string weatherDescription: ""
    property string currentWeatherIcon: ""
    property bool isCurrentDay: true

    // ============================================================================
    // DATA MODELS
    // ============================================================================

    readonly property alias hourModel: weatherHourList
    readonly property alias dailyModel: weatherDailyList

    ListModel {
        id: weatherHourList
    }

    ListModel {
        id: weatherDailyList
    }

    // ============================================================================
    // STATE MANAGEMENT
    // ============================================================================

    property bool dataAvailable: false
    property bool isLoading: false
    property bool hasFailed: false
    property bool wasCancelled: false

    // Retry logic
    property int retryCount: 0
    readonly property int maxRetries: 3

    // ============================================================================
    // CELESTIAL POSITION (0.0 - 1.0)
    // ============================================================================

    property string sunrise: "06:50"  // HH:MM format
    property string sunset: "17:00"   // HH:MM format
    property real currentHour: 12.0

    // Single position value: 0.0 = sunrise/sunset, 0.5 = noon/midnight, 1.0 = sunset/sunrise
    property real celestialPosition: 0.0

    property bool isDay: false
    property string timeOfDay: "Day"

    // Calculated properties
    readonly property real realSunriseHour: parseTime(sunrise)
    readonly property real realSunsetHour: parseTime(sunset)
    readonly property bool realIsDay: currentHour >= realSunriseHour && currentHour <= realSunsetHour

    // ============================================================================
    // DYNAMIC GRADIENT COLOR SETS
    // ============================================================================
    property var gradientStops: [Qt.vector3d(0.031, 0.031, 0.086), Qt.vector3d(0.122, 0.141, 0.259), Qt.vector3d(0.231, 0.184, 0.388)]

    // Color sets for different times of day
    readonly property var colorSets: ({
            "earlyMorning": [Qt.vector3d(0.031, 0.031, 0.086), Qt.vector3d(0.122, 0.141, 0.259), Qt.vector3d(0.231, 0.184, 0.388)],
            "morning": [Qt.vector3d(0.435, 0.525, 0.659), Qt.vector3d(0.655, 0.749, 0.863), Qt.vector3d(0.765, 0.871, 0.957)],
            "day": [Qt.vector3d(0.369, 0.627, 0.878), Qt.vector3d(0.498, 0.765, 0.961), Qt.vector3d(0.706, 0.863, 1.0)],
            "lateAfternoon": [Qt.vector3d(0.041, 0.416, 0.620), Qt.vector3d(0.7, 0.690, 0.478), Qt.vector3d(1.0, 0.878, 0.651)],
            "evening": [Qt.vector3d(0.090, 0.090, 0.08), Qt.vector3d(0.239, 0.165, 0.273), Qt.vector3d(0.353, 0.255, 0.325)],
            "night": [Qt.vector3d(0.024, 0.024, 0.071), Qt.vector3d(0.086, 0.086, 0.180), Qt.vector3d(0.149, 0.149, 0.290)]
        })

    // ============================================================================
    // TIME CALCULATION FUNCTIONS
    // ============================================================================

    // Parse "HH:MM" to decimal hours (e.g., "14:30" -> 14.5)
    function parseTime(timeStr) {
        if (!timeStr)
            return 0;
        const parts = timeStr.split(":");
        if (parts.length !== 2)
            return 0;
        return parseInt(parts[0]) + parseInt(parts[1]) / 60;
    }

    // Extract time from ISO 8601 format (e.g., "2026-02-02T06:50" -> "06:50")
    function extractTime(isoString) {
        if (!isoString)
            return "";
        const parts = isoString.split("T");
        if (parts.length !== 2)
            return "";
        return parts[1].substring(0, 5); // Extract HH:MM
    }

    // Calculate celestial position (0.0 - 1.0) works for both sun and moon
    function calculateCelestialPosition(hour, sunriseH, sunsetH) {
        if (hour >= sunriseH && hour <= sunsetH) {
            // Day time: sun position
            const dayDuration = sunsetH - sunriseH;
            if (dayDuration <= 0)
                return 0.5;
            return (hour - sunriseH) / dayDuration;
        } else {
            // Night time: moon position
            const nightDuration = 24 - (sunsetH - sunriseH);
            if (nightDuration <= 0)
                return 0.5;

            if (hour > sunsetH) {
                return (hour - sunsetH) / nightDuration;
            } else {
                return (hour + (24 - sunsetH)) / nightDuration;
            }
        }
    }

    // Get time of day category based on hour
    function getTimeOfDay(hour) {
        if (hour >= 5 && hour < 7)
            return "earlyMorning";
        if (hour >= 7 && hour < 10)
            return "morning";
        if (hour >= 10 && hour < 16)
            return "day";
        if (hour >= 16 && hour < 17)
            return "lateAfternoon";
        if (hour >= 17 && hour < 20)
            return "evening";
        return "night";
    }

    // Update gradient stops based on time of day
    function updateColors(hour) {
        const tod = getTimeOfDay(hour);
        const colors = colorSets[tod];

        if (!colors)
            return;

        root.gradientStops = colors;
        root.timeOfDay = tod.charAt(0).toUpperCase() + tod.slice(1);
    }

    // Main position calculation function
    function calculatePositions() {
        const now = new Date();
        const hour = now.getHours() + now.getMinutes() / 60;

        root.currentHour = hour;
        root.isDay = (hour >= realSunriseHour && hour <= realSunsetHour);

        // Calculate single celestial position (0.0 - 1.0)
        root.celestialPosition = calculateCelestialPosition(hour, realSunriseHour, realSunsetHour);

        // Update colors
        updateColors(hour);
        
        // Update current weather icon based on time of day
        root.currentWeatherIcon = getWeatherIcon(root.currentWeatherCode, root.isDay);
    }

    // Determine if a given hour is during daytime
    function isHourDaytime(hourString, sunriseTime, sunsetTime) {
        if (!sunriseTime || !sunsetTime) {
            const hour = parseInt(hourString.split(":")[0]);
            return hour >= 6 && hour < 18;
        }

        const sunriseHour = parseTime(sunriseTime);
        const sunsetHour = parseTime(sunsetTime);
        const currentHour = parseTime(hourString);

        return currentHour >= sunriseHour && currentHour < sunsetHour;
    }

    // ============================================================================
    // WEATHER CODE MAPPING FUNCTIONS
    // ============================================================================

    function getWeatherIcon(code, isDaytime) {
        const dn = isDaytime ? "-day" : "-night";

        switch (code) {
        case 0:
            return "weather-clear" + dn;
        case 1:
            return "weather-few-clouds" + dn;
        case 2:
            return "weather-clouds" + dn;
        case 3:
            return "weather-overcast" + dn;
        case 45:
        case 48:
            return "weather-fog";
        case 51:
        case 53:
        case 55:
            return "weather-showers-scattered" + dn;
        case 56:
        case 57:
            return "weather-freezing-rain";
        case 61:
        case 63:
        case 65:
            return "weather-showers" + dn;
        case 66:
        case 67:
            return "weather-freezing-rain";
        case 71:
        case 73:
        case 75:
            return isDaytime ? "weather-snow" : "weather-snow-night";
        case 77:
            return "weather-snow";
        case 80:
        case 81:
        case 82:
            return "weather-showers" + dn;
        case 85:
        case 86:
            return isDaytime ? "weather-snow" : "weather-snow-night";
        case 95:
            return isDaytime ? "weather-storm" : "weather-storm-night";
        case 96:
        case 99:
            return "weather-hail";
        default:
            return "weather-none-available";
        }
    }

    function getWeatherDescription(code) {
        const descMap = {
            0: "Clear sky",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog",
            48: "Depositing rime fog",
            51: "Light drizzle",
            53: "Moderate drizzle",
            55: "Dense drizzle",
            56: "Light freezing drizzle",
            57: "Dense freezing drizzle",
            61: "Slight rain",
            63: "Moderate rain",
            65: "Heavy rain",
            66: "Light freezing rain",
            67: "Heavy freezing rain",
            71: "Slight snowfall",
            73: "Moderate snowfall",
            75: "Heavy snowfall",
            77: "Snow grains",
            80: "Slight rain showers",
            81: "Moderate rain showers",
            82: "Violent rain showers",
            85: "Slight snow showers",
            86: "Heavy snow showers",
            95: "Thunderstorm",
            96: "Thunderstorm with slight hail",
            99: "Thunderstorm with heavy hail"
        };
        return descMap[code] || "Unknown";
    }

    // ============================================================================
    // DATA PROCESSING FUNCTIONS
    // ============================================================================

    function processWeatherData(data) {
        if (!data.hourly || !data.daily) {
            console.warn("WeatherService: Invalid weather response structure");
            return false;
        }

        const hourly = data.hourly;
        const daily = data.daily;

        weatherHourList.clear();
        weatherDailyList.clear();

        // Extract current weather if available
        if (data.current_weather) {
            root.currentWeatherCode = parseInt(data.current_weather.weathercode) || 0;
            root.currentTemp = Math.round(data.current_weather.temperature) || 0;
            root.windSpeed = Math.round(data.current_weather.windspeed) || 0;
            root.isCurrentDay = data.current_weather.is_day === 1;
            root.weatherDescription = getWeatherDescription(root.currentWeatherCode);
            root.currentWeatherIcon = getWeatherIcon(root.currentWeatherCode, root.isCurrentDay);
        }

        // Extract sunrise/sunset from daily data (first day = today)
        if (daily.sunrise && daily.sunrise.length > 0) {
            root.sunrise = extractTime(daily.sunrise[0]);
            console.log("WeatherService: Sunrise extracted:", root.sunrise);
        }
        if (daily.sunset && daily.sunset.length > 0) {
            root.sunset = extractTime(daily.sunset[0]);
            console.log("WeatherService: Sunset extracted:", root.sunset);
        }

        // Process hourly data
        const hourCount = hourly.time?.length || 0;
        for (let i = 0; i < hourCount; i++) {
            const timeString = hourly.time[i];
            const hourTime = extractTime(timeString); // "HH:MM"

            if (!hourTime)
                continue;

            const isDaytime = isHourDaytime(hourTime, root.sunrise, root.sunset);
            const code = hourly.weathercode?.[i] || 0;

            weatherHourList.append({
                time: timeString,
                hourTime: hourTime,
                temperature: Math.round(hourly.temperature_2m?.[i]) || 0,
                humidity: hourly.relative_humidity_2m?.[i] || 0,
                precipitation: hourly.precipitation_probability?.[i] || 0,
                windSpeed: Math.round(hourly.wind_speed_10m?.[i] || 0),
                icon: getWeatherIcon(code, isDaytime),
                description: getWeatherDescription(code),
                isDay: isDaytime
            });
        }
        console.log("WeatherService: Loaded", hourCount, "hourly forecasts");

        // Process daily data
        const dayCount = daily.time?.length || 0;
        for (let i = 0; i < dayCount; i++) {
            const timeString = daily.time[i];
            const dayDate = new Date(timeString);
            const dayName = i === 0 ? "Today" : Qt.formatDate(dayDate, "dddd");
            const code = daily.weathercode?.[i] || 0;

            // Extract sunrise/sunset for each day
            const daySunrise = daily.sunrise?.[i] ? extractTime(daily.sunrise[i]) : "";
            const daySunset = daily.sunset?.[i] ? extractTime(daily.sunset[i]) : "";

            weatherDailyList.append({
                date: timeString,
                dayName: dayName,
                index: i,
                weatherCode: code,
                maxTemp: Math.round(daily.temperature_2m_max?.[i] || 0),
                minTemp: Math.round(daily.temperature_2m_min?.[i] || 0),
                icon: getWeatherIcon(code, true),
                description: getWeatherDescription(code),
                sunrise: daySunrise,
                sunset: daySunset
            });
        }
        console.log("WeatherService: Loaded", dayCount, "daily forecasts");

        return true;
    }

    // ============================================================================
    // FETCH FUNCTION
    // ============================================================================

    function fetchWeather() {
        if (!root.enabled) {
            console.log("WeatherService: Disabled in config");
            return;
        }

        // Cancel any running process
        if (weatherProcess.running) {
            root.wasCancelled = true;
            weatherProcess.running = false;
        }

        root.isLoading = true;
        root.hasFailed = false;

        // Start the process
        weatherProcess.running = true;
    }

    // ============================================================================
    // ERROR HANDLING
    // ============================================================================

    function handleError(errorMsg) {
        console.warn("WeatherService: Error -", errorMsg);

        if (retryCount < maxRetries) {
            retryCount++;
            console.log("WeatherService: Retry attempt", retryCount, "of", maxRetries);
            retryTimer.start();
        } else {
            root.isLoading = false;
            root.hasFailed = true;
            root.retryCount = 0;
            console.error("WeatherService: Max retries reached");
        }
    }

    // ============================================================================
    // UNIFIED WEATHER PROCESS
    // ============================================================================

    Process {
        id: weatherProcess
        running: false
        command: ["curl", "-s", `https://api.open-meteo.com/v1/forecast?latitude=${root.latitude}&longitude=${root.longitude}&current_weather=true&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,wind_speed_10m,weathercode&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto&forecast_days=7&past_hours=0`]

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.wasCancelled) {
                    root.wasCancelled = false;
                    console.log("WeatherService: Fetch was cancelled");
                    return;
                }

                const raw = text.trim();
                if (!raw) {
                    root.handleError("Empty API response");
                    return;
                }

                try {
                    const data = JSON.parse(raw);

                    if (data.error) {
                        root.handleError(`API error: ${data.reason || data.error}`);
                        return;
                    }

                    if (processWeatherData(data)) {
                        root.dataAvailable = true;
                        root.isLoading = false;
                        root.retryCount = 0;
                        root.calculatePositions();
                        console.log("WeatherService: Data successfully loaded");
                    } else {
                        root.handleError("Failed to process weather data");
                    }
                } catch (e) {
                    root.handleError(`JSON parse error: ${e}`);
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    console.warn("WeatherService: curl stderr:", text.trim());
                }
            }
        }

        onExited: function (code) {
            if (code !== 0 && code !== 15 && !root.wasCancelled) {
                root.handleError(`Process exited with code ${code}`);
            }
        }
    }

    // ============================================================================
    // TIMERS
    // ============================================================================

    Timer {
        id: retryTimer
        interval: 5000  // 5 seconds between retries
        repeat: false
        onTriggered: root.fetchWeather()
    }

    Timer {
        id: refreshTimer
        interval: 600000  // 10 minutes
        running: root.enabled && root.dataAvailable
        repeat: true
        onTriggered: {
            console.log("WeatherService: Auto-refresh triggered");
            root.fetchWeather();
            root.calculatePositions();
        }
    }

    // ============================================================================
    // CONFIGURATION CONNECTIONS
    // ============================================================================

    Connections {
        target: Settings.config.weather

        function onLatitudeChanged() {
            console.log("WeatherService: Latitude changed, refetching...");
            root.fetchWeather();
        }

        function onLongitudeChanged() {
            console.log("WeatherService: Longitude changed, refetching...");
            root.fetchWeather();
        }

        function onEnabledChanged() {
            if (Settings.config.weather.enabled) {
                console.log("WeatherService: Enabled, fetching weather...");
                root.fetchWeather();
            } else {
                console.log("WeatherService: Disabled");
            }
        }
    }

    // ============================================================================
    // INITIALIZATION
    // ============================================================================

    Component.onCompleted: {
        const now = new Date();
        currentHour = now.getHours() + now.getMinutes() / 60;

        console.log("WeatherService: Initialized");
        console.log("WeatherService: Location:", root.latitude, root.longitude);
        console.log("WeatherService: Enabled:", root.enabled);

        if (root.enabled) {
            fetchWeather();
        }

        calculatePositions();
    }
}
