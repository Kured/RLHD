#version 330

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;
uniform float uWidth;
uniform float uHeight;
uniform float time;
uniform float colorBlindnessIntensity;
uniform vec3 uLightDirection;
uniform mat4 uLightProjectionMatrix;

#include utils/polyfills.glsl
#include postfx/effects/aa.glsl

out vec2 TexCoord;
out vec2 TexCoordAA;
out vec2 gScreenSpaceLightPos;

void main() {
    gl_Position = vec4(aPos, 1.0);
    TexCoord = aTexCoord;

    vec2 rcpFrame = vec2(1.0/uWidth, 1.0/uHeight);
    TexCoordAA.xy = aTexCoord.xy - (rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT));

    // Calculate the screen space position of the light
    vec4 lightClipPos = vec4(uLightDirection, 0.0) * uLightProjectionMatrix;
    vec3 lightNDC = lightClipPos.xyz / lightClipPos.w;
    gScreenSpaceLightPos = (lightNDC.xy + 1.0) * 0.5;

}