#version 330

#include utils/polyfills.glsl
#include uniforms/camera.glsl

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

uniform mat4 projectionMatrix;
uniform vec3 viewDirection;
uniform float skyboxRotation = 0.0; // degrees

out vec2 TexCoord;
out vec3 vViewDir;
out vec4 vPosition;

mat4 translateMatrix(vec3 translation)
{
    mat4 result = mat4(1.0);
    result[3] = vec4(translation, 1.0);
    return result;
}

mat4 rotateMatrixY(float rotation)
{
    float rot = 3.141592653589/180 * rotation;

    mat4 rotationMatrix = mat4(
        cos(rot), 0.0, sin(rot), 0.0,
        0.0, 1.0, 0.0, 0.0,
        -sin(rot), 0.0, cos(rot), 0.0,
        0.0, 0.0, 0.0, 1.0
    );
    return rotationMatrix;
}

void main()
{

/*
    // Regular Vertex Transformation
    gl_Position = projectionMatrix * vec4(aPos.x, aPos.y, aPos.z, 1.0);
    vPosition = gl_Position;
    vViewDir = viewDirection; //normalize(vPosition.xyz);
*/

    // Quad Rendered Sky
    gl_Position = vec4(aPos, 1.0);
    vPosition = -inverse(projectionMatrix * rotateMatrixY(skyboxRotation) ) * gl_Position;
    vViewDir = normalize(vPosition.xyz);

    TexCoord = aTexCoord;
}
