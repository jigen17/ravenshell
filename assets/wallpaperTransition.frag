#version 440

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    int transitionType;
    vec2 resolution;
    float time;
} ubuf;

layout(binding = 1) uniform sampler2D oldTexture;
layout(binding = 2) uniform sampler2D newTexture;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

const float PI = 3.14159265359;

void main() {
    vec2 uv = qt_TexCoord0;
    vec4 oldColor = texture(oldTexture, uv);
    vec4 newColor = texture(newTexture, uv);
    vec4 finalColor = oldColor;
    
    vec2 center = vec2(0.5, 0.5);
    vec2 fromCenter = uv - center;
    float dist = length(fromCenter);
    float angle = atan(fromCenter.y, fromCenter.x);
    
    // 0: Fade
    if (ubuf.transitionType == 0) {
        finalColor = mix(oldColor, newColor, ubuf.progress);
    }
    // 1: Grow (circle from center)
    else if (ubuf.transitionType == 1) {
        float maxDist = 0.71;
        float reveal = smoothstep(ubuf.progress * maxDist - 0.1, ubuf.progress * maxDist, dist);
        finalColor = mix(newColor, oldColor, reveal);
    }
    // 2: Outer (circle from edges)
    else if (ubuf.transitionType == 2) {
        float maxDist = 0.71;
        float reveal = smoothstep((1.0 - ubuf.progress) * maxDist, (1.0 - ubuf.progress) * maxDist + 0.1, dist);
        finalColor = mix(oldColor, newColor, reveal);
    }
    // 3: Wipe left
    else if (ubuf.transitionType == 3) {
        float reveal = smoothstep(ubuf.progress - 0.1, ubuf.progress, uv.x);
        finalColor = mix(newColor, oldColor, reveal);
    }
    // 4: Wipe right
    else if (ubuf.transitionType == 4) {
        float reveal = smoothstep(ubuf.progress - 0.1, ubuf.progress, 1.0 - uv.x);
        finalColor = mix(newColor, oldColor, reveal);
    }
    // 5: Wipe up
    else if (ubuf.transitionType == 5) {
        float reveal = smoothstep(ubuf.progress - 0.1, ubuf.progress, uv.y);
        finalColor = mix(newColor, oldColor, reveal);
    }
    // 6: Wipe down
    else if (ubuf.transitionType == 6) {
        float reveal = smoothstep(ubuf.progress - 0.1, ubuf.progress, 1.0 - uv.y);
        finalColor = mix(newColor, oldColor, reveal);
    }
    // 7: Zoom
    else if (ubuf.transitionType == 7) {
        float scale = 1.0 + (1.0 - ubuf.progress) * 0.5;
        vec2 zoomUV = (uv - center) * scale + center;
        vec4 zoomColor = texture(newTexture, zoomUV);
        if (zoomUV.x < 0.0 || zoomUV.x > 1.0 || zoomUV.y < 0.0 || zoomUV.y > 1.0) {
            zoomColor = vec4(0.0);
        }
        finalColor = mix(oldColor, zoomColor, ubuf.progress);
    }
    // 8: Wave
    else if (ubuf.transitionType == 8) {
        float wave = sin(uv.x * 10.0 - ubuf.progress * 6.28318) * 0.5 + 0.5;
        float reveal = smoothstep(ubuf.progress - 0.2, ubuf.progress + 0.2, wave);
        finalColor = mix(oldColor, newColor, reveal);
    }
    // 9: Spiral
    else if (ubuf.transitionType == 9) {
        float spiral = mod(angle / (2.0 * PI) + dist * 3.0 - ubuf.progress * 2.0, 1.0);
        float reveal = smoothstep(0.4, 0.6, spiral);
        finalColor = mix(newColor, oldColor, reveal);
    }
    // 10: Diamond
    else if (ubuf.transitionType == 10) {
        float diamond = abs(fromCenter.x) + abs(fromCenter.y);
        float reveal = smoothstep(ubuf.progress * 1.0 - 0.1, ubuf.progress * 1.0, diamond);
        finalColor = mix(newColor, oldColor, reveal);
    }
    // 11: Pixelate
    else if (ubuf.transitionType == 11) {
        float pixelSize = 0.01 + (1.0 - ubuf.progress) * 0.05;
        vec2 pixelUV = floor(uv / pixelSize) * pixelSize + pixelSize * 0.5;
        vec4 pixelOld = texture(oldTexture, pixelUV);
        vec4 pixelNew = texture(newTexture, pixelUV);
        float noise = fract(sin(dot(pixelUV, vec2(12.9898, 78.233))) * 43758.5453);
        float reveal = step(noise, ubuf.progress);
        finalColor = mix(pixelOld, pixelNew, reveal);
    }
    
    fragColor = finalColor * ubuf.qt_Opacity;
}
