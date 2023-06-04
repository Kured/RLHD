#version 330

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;
uniform float uWidth;
uniform float uHeight;

#include utils/polyfills.glsl
#include postfx/effects/aa.glsl

out vec2 TexCoord;
out vec2 TexCoordAA;

void main() {
    gl_Position = vec4(aPos, 1.0);
    TexCoord = aTexCoord;

    vec2 rcpFrame = vec2(1.0/uWidth, 1.0/uHeight);
    TexCoordAA.xy = aTexCoord.xy -
    (rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT));
}
