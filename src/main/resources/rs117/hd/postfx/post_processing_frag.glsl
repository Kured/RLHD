#version 330

#include uniforms/camera.glsl
#include utils/constants.glsl
#include utils/hdr.glsl

//#include postfx/utils/utils.glsl
#include postfx/effects/aa.glsl
#include postfx/effects/bloom.glsl
#include postfx/effects/dof.glsl
#include postfx/effects/dof_simple.glsl
#include postfx/effects/ssao.glsl
#include postfx/effects/godrays.glsl
//#include postfx/effects/godrays_simple.glsl
#include postfx/effects/toon.glsl
#include postfx/effects/motion_blur.glsl
#include postfx/effects/vignette.glsl

const bool DEBUG_INPUT_TEXTURES = false;
const bool DEBUG_SHADERS = false;

uniform sampler2D uBaseTexture;
uniform sampler2D uNormalTexture;
uniform sampler2D uOcclusionTexture;
uniform sampler2D uDepthTexture; // more channels available for more information storage
uniform sampler2D uShadowMapTexture;
uniform float time;
uniform float colorBlindnessIntensity;
uniform float uWidth; // Screen width
uniform float uHeight; // Screen height
uniform vec3 lightColor;
uniform float lightStrength;
uniform vec3 uLightDirection;
uniform mat4 uLightProjectionMatrix;
//uniform int samplingMode;

in vec2 TexCoord;
in vec2 TexCoordAA;
in vec2 gScreenSpaceLightPos;

out vec4 FragColor;

/*
    Todo:
        Create a multi-pass system for post-processing, so that we can have multiple effects at once.
        Notate which shaders require their own rendering pass.
        Blit the screen to a texture, then apply the post-processing effects to that texture.
        Repeat the process for each effect that requires it's own rendering pass
        If all toggled effects don't require their own rendering pass or it is just one, then continue as normal.

        Shaders that require Unique Pass:
        aa.glsl
        bloom.glsl

*/

vec3 renderNormals(vec3 normals)
{
    return (normals + 1.0) / 2.0;
}

void main()
{
    // base variables
    vec4 color = texture(uBaseTexture, TexCoord);
    vec3 normal = normalize(texture(uNormalTexture, TexCoord).rgb);
    vec3 occlusion = texture(uOcclusionTexture, TexCoord).rgb;
    vec3 depthData = texture(uDepthTexture, TexCoord).rgb;
    float linearDepth = LinearizeDepth(depthData.r);      // linear depth
    float depth = depthData.r;                            // depth
    float shadow = depthData.g;
    float emissive = depthData.b;
    float isTerrain = occlusion.g;
    float isSky = occlusion.b;
    vec2 rcpFrame = vec2(1.0/uWidth, 1.0/uHeight);

    // AA
    //aaFXAA(color, uBaseTexture, TexCoord, TexCoordAA, rcpFrame);

    // SSAO
    //if (isSky < 0.1)
    //    ssao(color, TexCoord, vec2(uWidth, uHeight), linearDepth, uDepthTexture, 1, 75);

    // God Rays
    //godrays(color, uOcclusionTexture, TexCoord, gScreenSpaceLightPos, uLightDirection);

    // God Rays Simple
    //godrays_simple(color, TexCoord, linearDepth, uWidth/uHeight, uLightDirection, uBaseTexture);

    // DoF
    //dof(color, uBaseTexture, TexCoord, linearDepth, rcpFrame, uNear, uFar, uDepthTexture);

    // DoF Simple
    //dof_simple(color, uBaseTexture, TexCoord, linearDepth, vec2(1.0 / uWidth, 1.0 / uHeight), uHeight/uWidth);

    // Bloom
    //bloom(color, uBaseTexture, uDepthTexture, TexCoord);

    // Toon
    //toon(color, TexCoord, uBaseTexture, uNormalTexture, uDepthTexture, vec2(1.0 / uWidth, 1.0 / uHeight), isTerrain, isSky, emissive); //

    // Motion Blur
    //motion_blur(color, TexCoord, uBaseTexture);

    // Vignette
    //vignette(color, TexCoord, uWidth, uHeight);

//    vec3 previousColor = texture(uTexPreviousFrame, TexCoord).rgb;
//    vec3 currentColor = texture(uBaseTexture, TexCoord).rgb;
//
//    // Compute the absolute difference between the texels
//    vec3 colorDiff = abs(currentColor - previousColor);

    FragColor = color;
    //FragColor = vec4(normal.rgb, 1);
    //color.rgb = pow(color.rgb, vec3(1.0/2.2));
    //FragColor = vec4(vec3(emissive), 1);
    //FragColor = vec4(color.rgb * vec3(pow(other, 2)*1.15 * (1 + worldDepth*0.2)), 1.0); //vec4(normal.rgb, 1); //vec4(vec3(LinearizeDepth(depth.r)), 1.0); /*vec4(normal.rgb, 1);*/ // LinearizeDepth // // postFX(baseTexture, time); //vec4(texture(baseTexture, TexCoord).rgb, .5); //

    if (DEBUG_INPUT_TEXTURES)
    {
        if (TexCoord.x < 0.25)
            FragColor = vec4(color.rgb, 1);
        else if (TexCoord.x >= 0.25 && TexCoord.x < 0.5)
            FragColor = vec4(renderNormals(normal.rgb), 1);
        else if (TexCoord.x >= 0.5 && TexCoord.x < 0.75)
            FragColor = vec4(vec3(1 - occlusion.r * 0.5), 1);
        else if (TexCoord.x >= 0.75 && TexCoord.x < 1.0)
            FragColor = vec4(vec3(linearDepth), 1);
    }
    else if (DEBUG_SHADERS)
    {
        if (TexCoord.x < 0.25)
            godrays(color, uOcclusionTexture, TexCoord, gScreenSpaceLightPos, uLightDirection);
        else if (TexCoord.x >= 0.25 && TexCoord.x < 0.5)
            ssao(color, TexCoord, vec2(uWidth, uHeight), linearDepth, uDepthTexture, 1, 75);
        else if (TexCoord.x >= 0.5 && TexCoord.x < 0.75)
            dof(color, uBaseTexture, TexCoord, linearDepth, rcpFrame, uNear, uFar, uDepthTexture);
        else if (TexCoord.x >= 0.75 && TexCoord.x < 1.0)
            bloom(color, uBaseTexture, uDepthTexture, TexCoord);

        FragColor = vec4(color.rgb, 1);
    }
}
