// Updated ShaderEffect in your QML file:

ShaderEffect {
    anchors.fill: parent
    property real iTime: 0.0
    property vector2d iResolution: Qt.vector2d(parent.width, parent.height)
    property real intensity: 1.0
    property real angle: -30
    
    // Pass gradient colors to shader
    property vector4d gradientColor1: Qt.vector4d(
        WeatherService.gradientStops[0].color.r,
        WeatherService.gradientStops[0].color.g,
        WeatherService.gradientStops[0].color.b,
        WeatherService.gradientStops[0].color.a
    )
    property vector4d gradientColor2: Qt.vector4d(
        WeatherService.gradientStops[1].color.r,
        WeatherService.gradientStops[1].color.g,
        WeatherService.gradientStops[1].color.b,
        WeatherService.gradientStops[1].color.a
    )
    property vector4d gradientColor3: Qt.vector4d(
        WeatherService.gradientStops[2].color.r,
        WeatherService.gradientStops[2].color.g,
        WeatherService.gradientStops[2].color.b,
        WeatherService.gradientStops[2].color.a
    )
    property real gradientPos1: WeatherService.gradientStops[0].position
    property real gradientPos2: WeatherService.gradientStops[1].position
    property real gradientPos3: WeatherService.gradientStops[2].position
    
    NumberAnimation on iTime {
        from: 0
        to: 1000
        duration: 1000000
        loops: Animation.Infinite
        running: true
    }

    vertexShader: "/home/mikaelio/ravenshell/assets/rain.vert.qsb"
    fragmentShader: "/home/mikaelio/ravenshell/assets/rain.frag.qsb"
}
