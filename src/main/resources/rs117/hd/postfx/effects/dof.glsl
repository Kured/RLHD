#include postfx/utils/utils.glsl

uniform float uFocusDistance = 0.7;
uniform float uFStop = 5.5;
uniform float uFocalLength = 29.9999; // 49.9999
uniform float uSensorHeight = 30.0;

uniform float MAX_BLUR_SIZE = 30.0;
uniform float RAD_SCALE = 1.0;   // Smaller = nicer blur, larger = faster
uniform float NUM_ITERATIONS = 50.0;

//uniform float uFocusDistance = 10;
//uniform float uFStop = 8.0;
//uniform float uFocalLength = 35.0;
//uniform float uSensorHeight = 24.0;
//
//uniform float MAX_BLUR_SIZE = 30.0;
//uniform float RAD_SCALE = 1.0;
//uniform float NUM_ITERATIONS = 50.0;

uniform bool uAutoFocus = true;
uniform bool uDOFDebug = false;
uniform bool uDepthDebug = false;

const float GOLDEN_ANGLE = 2.39996323;  // rad

float getLinearScreenDepth(vec2 uv, sampler2D texDepth)
{
    float depth = LinearizeDepth(texture(texDepth, uv).r);
    return depth;
}

float getFocusDistance(sampler2D texDepth)
{
    if (uAutoFocus)
    {
        float centerDepth = getLinearScreenDepth(vec2(0.501, 0.501), texDepth);
        float depthBias = 0.0001; // Adjust this value as needed
        return centerDepth + depthBias;
    }
    return uFocusDistance;
}


float ndcDepthToEyeSpace(float ndcDepth, float near, float far) {
    return (far - near) * (ndcDepth + (far + near) / (far - near)) / 2.0;
}

float readDepth(vec2 uv, float depth, float near, float far) {
    float z_b = depth;
    float z_n = 2.0 * z_b - 1.0;
    return ndcDepthToEyeSpace(z_n, near, far);
}

float getCoCSize(float depth, float focusDistance, float maxCoC) {
    float coc = clamp((1.0 - focusDistance / depth) * maxCoC, -1.0, 1.0); // (1 - mm/mm) * mm = mm
    return abs(coc) * MAX_BLUR_SIZE;
}

vec3 _dof(sampler2D tex, vec2 uv, float focusDistance, float maxCoC, float depthIn, vec2 rcpFrame, sampler2D texDepth)
{
    float resolutionScale = 1; //imageSize.y / 1080.0;
    float centerDepth = depthIn * 1000.0; //  readDepth(uv, uNear, uFar) * 1000.0; //m -> mm
    float centerSize = getCoCSize(centerDepth, focusDistance, maxCoC);

    if (uDOFDebug && uv.x > 0.5) {
        float coc = (1.0 - focusDistance / centerDepth) * maxCoC;
        if (uv.x > 0.90) {
            float depth = uv.y * 1000.0 * 100.0; //100m
            if (uv.x <= 0.95) {
                float t = (uv.x - 0.9) * 20.0;
                float coc = (1.0 - focusDistance / depth) * maxCoC * 10.0;
                coc = abs(coc);
                if (coc > t) return vec3(1.0);
                return vec3(0.0);
            }
            if (uv.x > 0.97) {
                if (depth > focusDistance - 250.0 && depth < focusDistance + 250.0) {
                    return vec3(1.0, 1.0, 0.0);
                }
                return vec3(floor(uv.y * 10.0)) / 10.0;
            }
            float c = 0.03; //0.03mm for 35mm format
            float H = uFocalLength * uFocalLength / (uFStop * c); //mm
            float Dn = H * focusDistance / (H + focusDistance);
            float Df = H * focusDistance / (H - focusDistance);
            if (depth > H - 250.0 && depth < H + 250.0) return vec3(1.0, 1.0, 0.0);
            if (depth < Dn) return vec3(1.0, 0.0, 0.0);
            if (depth > Df) return vec3(1.0, 0.0, 0.0);
            return vec3(0.0, 1.0, 0.0);
        }

        return vec3(floor(abs(coc) / 0.1 * 100.0) / 100.0, 0.0, 0.0);
        float c = abs(coc);
        c = c / (1.0 + c); // tonemapping to avoid burning the color
        c = pow(c, 2.2); // gamma to linear
        if (coc > 0.0) return vec3(c, 0.0, 0.0);
        else return vec3(0.0, 0.0, c);

    }
    if (uDepthDebug && uv.x > 0.5)
    {
        float vDepth = depthIn;
        return vec3(vDepth / uFStop);
    }

    vec3 color = texture2D(tex, uv).rgb;
    float tot = 1.0;
    float radius = RAD_SCALE;
    for (float ang = 0.0; ang < GOLDEN_ANGLE * NUM_ITERATIONS; ang += GOLDEN_ANGLE){
        vec2 tc = uv + vec2(cos(ang), sin(ang)) * rcpFrame * radius * resolutionScale;
        vec3 sampleColor = texture2D(tex, tc).rgb;
        float sampleDepth = depthIn * 1000.0; // readDepth(tc, uNear, uFar) * 1000.0; //m -> mm;
        float sampleSize = getCoCSize(sampleDepth, focusDistance, maxCoC);
        if (sampleDepth > centerDepth)
        sampleSize = clamp(sampleSize, 0.0, centerSize * 2.0);
        float m = smoothstep(radius - 0.5, radius + 0.5, sampleSize);
        color += mix(color/tot, sampleColor, m);
        tot += 1.0;
        radius += RAD_SCALE / radius;
        // Not sure if this ever happens as we exit after 50 iterations anyway
        if (radius > MAX_BLUR_SIZE) {
            break;
        }
    }

    return color /= tot;
}

void dof(inout vec4 color, sampler2D tex, vec2 uv, float depth, vec2 rcpFrame, float near, float far, sampler2D texDepth)
{
    float F = uFocalLength;
    float A = F / uFStop;
    float focusDistance = getFocusDistance(texDepth) * 1000.0; // m -> mm
    float maxCoC = A * F / (focusDistance - F); //mm * mm / mm = mm

    // blend _dof output with color

    color.rgb = _dof(tex, uv, focusDistance, maxCoC, depth, rcpFrame, texDepth);

    //color.rgb = Uncharted2ToneMapping(color.rgb);
}


// varying vec2 vTexCoord0;
// uniform sampler2D depthMap; //Linear depth, where 1.0 == far plane

//uniform sampler2D uBaseTexture; //Image to be processed
//uniform vec2 imageSize;
//uniform vec2 uPixelSize; //The size of a pixel: vec2(1.0/width, 1.0/height)
//
//uniform float uFar; // Far plane
//uniform float uNear;







// float MAX_BLUR_SIZE = 30.0;
// float RAD_SCALE = 1.0; // Smaller = nicer blur, larger = faster
// float NUM_ITERATIONS = 50.0;

// float depth = getLinearScreenDepth(vUv0);

//void main () {
//    float F = uFocalLength;
//    float A = F / uFStop;
//    float focusDistance = getFocusDistance() * 1000.0; // m -> mm
//    float maxCoC = A * F / (focusDistance - F); //mm * mm / mm = mm
//    vec3 color = depthOfField(vUv0, focusDistance, maxCoC);
//
//    gl_FragColor = vec4(color, 1.0);
//}

// Vigentte
