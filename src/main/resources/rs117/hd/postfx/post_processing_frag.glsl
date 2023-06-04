#version 330

#include uniforms/camera.glsl
#include utils/constants.glsl

#include postfx/effects/aa.glsl
#include postfx/effects/bloom.glsl

uniform sampler2D baseTexture;
uniform sampler2D normalTexture;
uniform sampler2D depthTexture;
uniform float time = 0.0;
uniform float uWidth;
uniform float uHeight;
uniform float colorBlindnessIntensity;
uniform int samplingMode;

in vec2 TexCoord;
in vec2 TexCoordAA;
out vec4 FragColor;

vec4 alphaBlend(vec4 src, vec4 dst) {
    return vec4(
        src.rgb + dst.rgb * (1.0f - src.a),
        src.a + dst.a * (1.0f - src.a)
    );
}

vec4 postFX(sampler2D tex, float time)
{
    vec4 c = vec4(texture(tex, TexCoord).rgb, 1.0);
    vec2 rcpFrame = vec2(1.0/uWidth, 1.0/uHeight);

    // AA
    //c.rgb = aaFXAA(tex, TexCoord, TexCoordAA, rcpFrame);

    return c;
}

void main() {
    FragColor = vec4(vec3(texture(baseTexture, TexCoord).rgb), 1); //vec4(vec3(texture(depthTexture, TexCoord).rgb), 1.0); // postFX(baseTexture, time); //vec4(texture(baseTexture, TexCoord).rgb, .5); //
}
