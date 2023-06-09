//uniform vec2 uScreenSpaceSunPos = vec2(0.5, 0.5);
uniform float uDensity = 0.9;
uniform float uWeight = 0.1;
uniform float uDecay = 0.95;
uniform float uExposure = 0.1;
uniform int uNumSamples = 64;

//uniform sampler2D uOcclusionTexture;

void godrays(inout vec4 color, sampler2D occlusionTexture, vec2 uv, vec2 screenSpaceLightPos, vec3 lightDir)
{
    vec3 fragColor = vec3(0.0);

    vec2 deltaTextCoord = uv - screenSpaceLightPos;

    vec2 textCoo = uv;
    deltaTextCoord *= (1.0 / float(uNumSamples)) * uDensity;
    float illuminationDecay = 1.0;

    for (int i = 0; i < uNumSamples; i++)
    {
        textCoo -= deltaTextCoord;
        vec3 samp = vec3(1 - texture2D(occlusionTexture, textCoo).r);
        samp *= illuminationDecay * uWeight;
        fragColor += samp;
        illuminationDecay *= uDecay;
    }

    fragColor *= uExposure;

    // Blend the god rays with the main color using additive blending
    color.rgb += fragColor;

    // Optionally, you can clamp the resulting color to prevent over-brightening
    color.rgb = clamp(color.rgb, 0.0, 1.0);
}