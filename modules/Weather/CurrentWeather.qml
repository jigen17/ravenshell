import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets

Item {
    id: weatherView
    ClippingRectangle {
        id: root
        anchors.fill: parent
        radius: 18
        clip: true

        ShaderEffect {
            anchors.fill: parent
            property vector3d color0: WeatherService.gradientStops[0]
            property vector3d color1: WeatherService.gradientStops[1]
            property vector3d color2: WeatherService.gradientStops[2]

            property real iTime: 0
            property vector2d iResolution: Qt.vector2d(width, height)
            property real isSun: WeatherService.isDay
            property real t: WeatherService.celestialPosition 
            property real rx: width / 2  
            property real ry: 80 
            property real cx: width / 2 
            property real cy: height / 2 
            property real startAngle: Math.PI * 0.75 
            property real endAngle: Math.PI * 0.25 
            property real angle: startAngle + (endAngle - startAngle) * t // Normalize to 0-1 range for shader //
            property vector2d sunPosition: Qt.vector2d((cx + rx * Math.cos(angle)) / width, (cy - ry * Math.sin(angle)) / height)
            property int weatherCode: WeatherService.currentWeatherCode

            NumberAnimation on iTime {
                from: 0
                to: 10
                duration: 50000
                loops: Animation.Infinite
                running: true
            }
              vertexShader: "/home/mikaelio/ravenshell/assets/weather.vert.qsb"
            fragmentShader: "/home/mikaelio/ravenshell/assets/weather.frag.qsb"
        }

        // Stars shader effect (fixed)

        // Weather description
        Rectangle {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 10
                rightMargin: 10
            }
            color: "lightgrey"
            radius: 18
            implicitHeight: 30
            implicitWidth: Math.max(descriptionText.width + 20, 60)
            opacity: 0.7
            RavenText {
                id: descriptionText
                anchors.centerIn: parent
                fontSize: 12
                text: WeatherService.weatherDescription
            }
        }
    }

}
