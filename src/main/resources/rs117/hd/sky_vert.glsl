#version 330

#include UI_SCALING_MODE

#define SAMPLING_DEFAULT 0
#define SAMPLING_MITCHELL 1
#define SAMPLING_CATROM 2
#define SAMPLING_XBR 3

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

#if UI_SCALING_MODE == SAMPLING_XBR
#include scaling/xbr_lv2_vert.glsl

out XBRTable xbrTable;
#endif

#include utils/polyfills.glsl
#include uniforms/camera.glsl

uniform mat4 projectionMatrix;

out vec2 TexCoord;
out vec4 vPosition;
out vec3 vViewDir;

void main() {
    gl_Position = vec4(aPos, 1.0);
    mat4 projMat = projectionMatrix;
    projMat[3][0] = projMat[3][1] = projMat[3][2] = 0.0;

    gl_Position = vec4(aPos, 1.0);
    gl_Position.z -= 0.05;

    vPosition = gl_Position * -projMat;
    vViewDir = normalize(vPosition.xyz);

    TexCoord = aTexCoord;
}
