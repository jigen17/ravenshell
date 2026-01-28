
#version 440

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    int transitionType;
    vec2 resolution;
    float time;
} ubuf;

layout(location = 0) out vec2 qt_TexCoord0;

void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;

    vec4 pos = qt_Vertex;

    if (ubuf.transitionType == 8) {
        float wave = sin(qt_MultiTexCoord0.x * 10.0 + ubuf.progress * 6.28318)
                     * 0.05 * (1.0 - ubuf.progress);
        pos.y += wave;
    }

    gl_Position = ubuf.qt_Matrix * pos;
}

