#version 330

#include skybox/sky.glsl
#include uniforms/camera.glsl

uniform samplerCube cubemapTexture;
uniform vec3 skyboxColor; // at horizon to up
uniform vec3 lightDirection;
uniform vec3 viewDirection;

// Unused
uniform float colorBlindnessIntensity;
uniform mat4 projectionMatrix;

in vec2 TexCoord;
in vec3 vViewDir;
in vec4 vPosition;

out vec4 FragColor;

void main() {
    vec3 pos = vPosition.xyz;

    //FragColor = renderSky(vViewDir, lightDirection, skyboxColor);
    FragColor = renderCubemap(cubemapTexture, pos, lightDirection);
}
