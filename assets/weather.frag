#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    vec3 color0;
    vec3 color1;
    vec3 color2;
    float iTime;
    vec2 iResolution;
    vec2 sunPosition;
    float isSun; // 1.0 = sun, 0.0 = moon
    int weatherCode; // WMO weather code
};

const int NUM_CLOUDS = 20;
const int NUM_STARS = 30;
const int NUM_PRECIPITATION = 60;
const int NUM_FOG_LAYERS = 10;

// ==================== UTILITY FUNCTIONS ====================
float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453);
}

// ==================== FOG FUNCTIONS ====================
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for(int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

float fogLayer(vec2 uv, float offset, float speed, float scale) {
    vec2 p = uv * scale;
    p.x += iTime * speed + offset;
    float fog = fbm(p);
    fog += fbm(p * 2.0 + vec2(iTime * speed * 0.5, 0.0)) * 0.5;
    return fog;
}

// ==================== CLOUD FUNCTIONS ====================
float puff(vec2 uv, vec2 pos, float r) {
    float d = length(uv - pos);
    return smoothstep(r, r * 0.55, d);
}

float cloudShape(vec2 uv, vec2 pos, float seed) {
    float cloud = 0.0;
    float jx = (rand(vec2(seed, 1.0)) - 0.5) * 0.05;
    float jy = (rand(vec2(seed, 2.0)) - 0.5) * 0.03;
    
    float b1 = 0.070 + rand(vec2(seed, 3.0)) * 0.015;
    float b2 = 0.080 + rand(vec2(seed, 4.0)) * 0.015;
    float b3 = 0.070 + rand(vec2(seed, 5.0)) * 0.015;
    float t1 = 0.055 + rand(vec2(seed, 6.0)) * 0.010;
    float t2 = 0.055 + rand(vec2(seed, 7.0)) * 0.010;
    
    cloud = max(cloud, puff(uv, pos + vec2(-0.07 + jx, -0.02), b1));
    cloud = max(cloud, puff(uv, pos + vec2( 0.00 + jx, -0.03), b2));
    cloud = max(cloud, puff(uv, pos + vec2( 0.07 + jx, -0.02), b3));
    cloud = max(cloud, puff(uv, pos + vec2(-0.04 + jx, -0.05 + jy), t1));
    cloud = max(cloud, puff(uv, pos + vec2( 0.04 + jx, -0.05 + jy), t2));
    
    return cloud;
}

// ==================== MAIN ====================
void main() {
    vec2 uv = qt_TexCoord0;
    float wc = float(weatherCode);
    
    // ==================== WEATHER PARAMETERS (NO IFS!) ====================
    // Use step functions to create masks
    float isClear = step(wc, 0.5) * step(-0.5, -wc); // exactly 0
    float isPartlyCloudy = step(1.0, wc) * step(wc, 3.0);
    float isFoggy = step(45.0, wc) * step(wc, 48.0);
    
    // Drizzle: 51-57
    float isDrizzle = step(51.0, wc) * step(wc, 57.0);
    
    // Rain: 61-67 or 80-82
    float isRain1 = step(61.0, wc) * step(wc, 67.0);
    float isRain2 = step(80.0, wc) * step(wc, 82.0);
    float isRain = clamp(isRain1 + isRain2, 0.0, 1.0);
    
    // Snow: 71-77 or 85-86
    float isSnow1 = step(71.0, wc) * step(wc, 77.0);
    float isSnow2 = step(85.0, wc) * step(wc, 86.0);
    float isSnow = clamp(isSnow1 + isSnow2, 0.0, 1.0);
    
    // Thunderstorm: 95-99
    float isThunderstorm = step(95.0, wc) * step(wc, 99.0);
    
    // Precipitation intensity (0-3)
    float isLight = step(wc, 51.5) * step(50.5, wc) + // 51
                    step(wc, 56.5) * step(55.5, wc) + // 56
                    step(wc, 61.5) * step(60.5, wc) + // 61
                    step(wc, 66.5) * step(65.5, wc) + // 66
                    step(wc, 71.5) * step(70.5, wc) + // 71
                    step(wc, 80.5) * step(79.5, wc) + // 80
                    step(wc, 85.5) * step(84.5, wc);  // 85
    
    float isModerate = step(wc, 53.5) * step(52.5, wc) + // 53
                       step(wc, 63.5) * step(62.5, wc) + // 63
                       step(wc, 73.5) * step(72.5, wc) + // 73
                       step(wc, 81.5) * step(80.5, wc);  // 81
    
    float isHeavy = step(wc, 55.5) * step(54.5, wc) + // 55
                    step(wc, 57.5) * step(56.5, wc) + // 57
                    step(wc, 65.5) * step(64.5, wc) + // 65
                    step(wc, 67.5) * step(66.5, wc) + // 67
                    step(wc, 75.5) * step(74.5, wc) + // 75
                    step(wc, 82.5) * step(81.5, wc) + // 82
                    step(wc, 86.5) * step(85.5, wc);  // 86
    
    float precipIntensity = isLight * 1.0 + isModerate * 2.0 + isHeavy * 3.0 + isThunderstorm * 3.0;
    
    // Cloud coverage
    float cloudCoverage = 0.0;
    cloudCoverage += step(wc, 1.5) * step(0.5, wc) * 0.3; // code 1
    cloudCoverage += step(wc, 2.5) * step(1.5, wc) * 0.6; // code 2
    cloudCoverage += step(wc, 3.5) * step(2.5, wc) * 0.9; // code 3
    cloudCoverage += (isRain + isSnow + isThunderstorm + isDrizzle * 0.7) * 0.9;
    cloudCoverage = clamp(cloudCoverage, 0.0, 1.0);
    
    float fogIntensity = isFoggy * 1.8;
    
    // ==================== BACKGROUND GRADIENT ====================
    vec3 sky = mix(mix(color0, color1, uv.y), mix(color1, color2, uv.y), uv.y);
    
    // Darken for storms (no if!)
    float stormDarken = isThunderstorm * 0.4 + (1.0 - isThunderstorm) * (isRain * step(2.0, precipIntensity) * 0.6 + (1.0 - isRain * step(2.0, precipIntensity)));
    sky *= stormDarken;
    
    // ==================== STARS (render first, at bottom layer) ====================
    vec3 starColor = vec3(0.0);
    float sunMask = step(0.5, isSun);
    float moonMask = 1.0 - sunMask;
    float starCondition = moonMask * step(cloudCoverage, 0.5) * (1.0 - isFoggy);
    float starVisibility = (1.0 - cloudCoverage * 2.0);
    float inStarRegion = step(0.3, 1.0 - uv.y); // Stars in upper region
    
    for (int i = 0; i < NUM_STARS; i++) {
        float fi = float(i);
        vec2 starPos = vec2(rand(vec2(fi, fi * 1.3)), 1.0 - (0.7 + 0.3 * rand(vec2(fi * 1.7, fi * 0.9))));
        float starDist = length(uv - starPos);
        int sizeIndex = int(mod(fi * 7.0, 3.0));
        float starSize = 0.001 + float(sizeIndex) * 0.0005;
        float twinkleSpeed = 2.0 + 3.0 * rand(vec2(fi * 5.2, fi * 6.7));
        float twinkle = 0.4 + 0.6 * sin(iTime * 6.28 * twinkleSpeed + fi * 6.28);
        float brightness = twinkle * smoothstep(starSize * 4.0, 0.0, starDist);
        float colorMix = (twinkle - 0.4) / 0.6;
        vec3 sColor = mix(color0, vec3(1.0), colorMix);
        starColor += brightness * sColor * inStarRegion * starVisibility * starCondition;
    }
    sky += starColor;
    
    // ==================== SUN/MOON (render on top of stars) ====================
    vec2 celestialUV = uv - sunPosition;
    float dist = length(celestialUV);
    
    // Fog obscuration factor
    float fogDensityAtCelestial = 0.0;
    for(int i = 0; i < 5; i++) {
        float fi = float(i);
        float offset = rand(vec2(fi, 100.0)) * 100.0;
        float speed = 0.01 + rand(vec2(fi, 200.0)) * 0.02;
        float scale = 1.5 + rand(vec2(fi, 300.0)) * 3.0;
        fogDensityAtCelestial += fogLayer(sunPosition, offset, speed, scale) * 0.15 * isFoggy;
    }
    fogDensityAtCelestial = clamp(fogDensityAtCelestial * fogIntensity, 0.0, 0.9);
    
    // Cloud obscuration
    float cloudObscure = cloudCoverage * 0.7;
    
    // SUN
    float sunDisc = smoothstep(0.12, 0.06, dist) * (1.0 - fogDensityAtCelestial - cloudObscure);
    float sunGlow = clamp(0.2 / (dist + 0.1), 0.0, 1.0) * (1.0 - fogDensityAtCelestial * 0.5 - cloudObscure * 0.5);
    vec3 sunColor = vec3(1.0, 0.95, 0.85);
    vec3 sunResult = mix(sky, sunColor, sunDisc * 0.6);
    sunResult += sunColor * sunGlow * 0.15;
    
    // MOON
    float moonDisc = smoothstep(0.08, 0.06, dist) * (1.0 - fogDensityAtCelestial - cloudObscure);
    vec2 craterUV = celestialUV * 15.0;
    float crater1 = smoothstep(0.4, 0.0, length(craterUV - vec2(0.3, 0.2)));
    float crater2 = smoothstep(0.3, 0.0, length(craterUV - vec2(-0.4, -0.1)));
    float crater3 = smoothstep(0.25, 0.0, length(craterUV - vec2(0.1, -0.3)));
    float craters = crater1 * 0.3 + crater2 * 0.25 + crater3 * 0.2;
    vec3 moonColor = vec3(0.9, 0.9, 0.95);
    vec3 moonShaded = moonColor * (0.85 - craters);
    float moonGlow = clamp(0.08 / (dist + 0.1), 0.0, 1.0) * (1.0 - fogDensityAtCelestial * 0.5 - cloudObscure * 0.5);
    vec3 moonResult = mix(sky, moonShaded, moonDisc * 0.5);
    moonResult += moonColor * moonGlow * 0.1;
    
    sky = sunResult * sunMask + moonResult * moonMask;
    
    // ==================== LIGHTNING ====================
    float flashTime = iTime * 2.0;
    float flashNoise = rand(vec2(floor(flashTime), 0.0));
    float flashTrigger = step(0.95, flashNoise);
    float flashPhase = fract(flashTime);
    float flashIntensity = flashTrigger * (1.0 - smoothstep(0.0, 0.15, flashPhase));
    vec3 lightningColor = vec3(0.7, 0.8, 1.0) * flashIntensity * 0.6 * isThunderstorm;
    sky += lightningColor;
    
    // ==================== RAIN (0.8 and below) ====================
    float rainMask = clamp(isRain + isThunderstorm, 0.0, 1.0);
    vec2 uvFlipped = vec2(uv.x, 1.0 - uv.y);
    // Hardcoded rainAngle at 0.8
    float angleRad = mix(-2.356194, 0.785398, (0.8 + 1.0) * 0.5);
    vec2 dir = normalize(vec2(sin(angleRad), -cos(angleRad)));
    vec3 rainColor = vec3(0.0);
    
    // Rain only visible from y=0.8 and below (which is uv.y <= 0.2 in flipped coords)
    float rainVisibleRegion = 1. - step(uv.y, 0.3);
    
    for(int i = 0; i < NUM_PRECIPITATION; i++) {
        float fi = float(i);
        float dropIndex = fi / float(NUM_PRECIPITATION);
        float activeDrop = step(dropIndex, 0.5 + precipIntensity * 0.15) * rainMask;
        
        vec2 startPos = vec2(rand(vec2(fi, fi*1.3)), rand(vec2(fi, fi*5.2)));
        float fallSpeed = 0.30 + 0.25 * rand(vec2(fi*2.7, fi*3.1));
        fallSpeed *= (1.0 + precipIntensity * 0.15);
        
        vec2 rainPos = startPos + dir * iTime * fallSpeed;
        rainPos = fract(rainPos);
        vec2 toDrop = uvFlipped - rainPos;
        toDrop.x *= iResolution.x / iResolution.y;
        
        float rotAngle = angleRad + 1.570796;
        float cosA = cos(rotAngle);
        float sinA = sin(rotAngle);
        vec2 r = vec2(toDrop.x * sinA - toDrop.y * cosA, toDrop.x * cosA + toDrop.y * sinA);
        
        float dropWidth = 0.0015;
        float dropHeight = 0.040 + 0.020 * rand(vec2(fi*7.1, fi*8.2));
        float rect = smoothstep(0.0, dropWidth, dropWidth - abs(r.x)) * smoothstep(0.0, dropHeight, dropHeight - abs(r.y));
        float opacity = 0.35 + 0.45 * rand(vec2(fi*9.3, fi*10.4));
        rainColor += rect * opacity * vec3(0.75, 0.85, 1.0) * activeDrop * rainVisibleRegion;
    }
    
    rainColor += rainColor * step(0.01, length(lightningColor)) * 1.5;
    sky += rainColor * 0.6;
    
    // ==================== SNOW (full screen) ====================
    vec3 snowColor = vec3(0.0);
    
    for (int i = 0; i < NUM_PRECIPITATION; i++) {
        float fi = float(i);
        float flakeIndex = fi / float(NUM_PRECIPITATION);
        float activeFlake = step(flakeIndex, 0.5 + precipIntensity * 0.15) * isSnow;
        
        float startX = rand(vec2(fi, fi * 1.3));
        float fallSpeed = 0.30 + 0.25 * rand(vec2(fi * 1.7, fi * 0.9));
        fallSpeed *= (1.0 + precipIntensity * 0.15);
        
        float driftAmount = 0.03 * rand(vec2(fi * 2.1, fi * 3.4));
        float driftSpeed = 0.5 + 0.5 * rand(vec2(fi * 4.2, fi * 5.3));
        float drift = driftAmount * sin(iTime * driftSpeed + fi * 6.28);
        float yPos = mod(1.0 + rand(vec2(fi * 5.2, fi * 6.7)) + iTime * fallSpeed, 1.0);
        vec2 snowPos = vec2(mod(startX + drift, 1.0), yPos);
        float snowDist = length(uv - snowPos);
        int sizeIndex = int(mod(fi * 7.0, 3.0));
        float snowSize = 0.002 + float(sizeIndex) * 0.001;
        float brightness = smoothstep(snowSize * 3.0, 0.0, snowDist);
        float opacity = 0.7 + 0.3 * rand(vec2(fi * 8.1, fi * 9.2));
        snowColor += brightness * opacity * vec3(1.0) * activeFlake;
    }
    sky += snowColor;
    
    // ==================== CLOUDS (0.7 to 0.1 - on top of rain) ====================
    float clouds = 0.0;
    float cloudMask = step(0.01, cloudCoverage);
    
    for(int i = 0; i < NUM_CLOUDS; i++) {
        float fi = float(i);
        float cloudIndex = fi / float(NUM_CLOUDS);
        float activeCloud = step(cloudIndex, cloudCoverage);
        
        float startX = rand(vec2(fi, 10.0));
        float speed = 0.03 + rand(vec2(fi, 20.0)) * 0.02;
        float x = fract(startX + iTime * speed) * 1.2 - 0.1;
        // Clouds between y=0.1 and y=0.7
        float y = 0.1 + rand(vec2(fi, 30.0)) * 0.3;
        clouds = max(clouds, cloudShape(uv, vec2(x, y), fi * 99.0) * activeCloud);
    }
    
    // Fade clouds at bottom (y=0.1) and don't fade at top
    float fade = smoothstep(0.0, 0.15, uv.y);
    vec3 cloudColor = mix(vec3(0.28), vec3(1.0), 1.0 - isThunderstorm);
    cloudColor += lightningColor * 0.4;
    sky = mix(sky, cloudColor, clouds * fade * 0.85 * cloudMask);
    
    // ==================== FOG (top layer) ====================
    float fogDensity = 0.0;
    for(int i = 0; i < NUM_FOG_LAYERS; i++) {
        float fi = float(i);
        float offset = rand(vec2(fi, 100.0)) * 100.0;
        float speed = 0.01 + rand(vec2(fi, 200.0)) * 0.02;
        float scale = 1.5 + rand(vec2(fi, 300.0)) * 3.0;
        float layerStrength = 0.18 / float(NUM_FOG_LAYERS);
        fogDensity += fogLayer(uv, offset, speed, scale) * layerStrength * isFoggy;
    }
    
    float heightGradient = smoothstep(0.9, 0.0, uv.y);
    fogDensity *= heightGradient * 1.3;
    float depthNoise = fbm(uv * 1.5 + vec2(iTime * 0.005, 0.0));
    fogDensity *= 0.6 + depthNoise * 0.4;
    fogDensity = clamp(fogDensity * fogIntensity, 0.0, 0.95);
    
    vec3 fogColor = mix(color1, vec3(0.95, 0.96, 0.98), 0.4);
    vec3 fogTint = mix(fogColor, color2, uv.y * 0.15);
    float celestialInfluence = clamp(0.5 / (dist + 0.2), 0.0, 1.0);
    vec3 celestialColor = sunColor * sunMask + moonColor * moonMask;
    fogTint = mix(fogTint, celestialColor, celestialInfluence * 0.25 * (1.0 - fogDensity * 0.3));
    sky = mix(sky, fogTint, fogDensity);
    
    fragColor = vec4(sky, 1.0);
}
