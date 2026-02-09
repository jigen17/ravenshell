#version 440
layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;
layout(location = 0) out vec2 qt_TexCoord0;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec3 color0;
    vec3 color1;
    vec3 color2;
    float iTime;  // Add this to your uniform buffer
    vec2 iResolution;  // Add this to your uniform buffer
        vec2 sunPosition;
    float isSun; // 1.0 = sun, 0.0 = moon
    int weatherCode; // WMO weather code
};

void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
