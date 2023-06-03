#version 330

#include uniforms/camera.glsl
//#include uniforms/materials.glsl
//#include uniforms/water_types.glsl
//#include uniforms/lights.glsl
#include utils/constants.glsl

uniform sampler2D baseTexture;
uniform float time;
uniform int samplingMode;
uniform float colorBlindnessIntensity;

in vec2 TexCoord;

out vec4 FragColor;

vec4 alphaBlend(vec4 src, vec4 dst) {
    return vec4(
    src.rgb + dst.rgb * (1.0f - src.a),
    src.a + dst.a * (1.0f - src.a)
    );
}

void main() {
    FragColor = texture(baseTexture, TexCoord); // vec4(0, 0, 0, 1); //
}
