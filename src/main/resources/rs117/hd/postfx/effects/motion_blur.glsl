uniform sampler2D uTexPreviousFrame;
uniform float blurAmount = 0.4;
uniform float maxBlurStrength = 1.0;

void motion_blur(inout vec4 color, vec2 uv, sampler2D tex)
{
    vec4 currentColor = texture(tex, uv);
    vec4 previousColor = texture(uTexPreviousFrame, uv);

    vec3 colorDelta = currentColor.rgb - previousColor.rgb;
    float distance = length(colorDelta);
    vec3 direction = colorDelta / distance;

    float blurStrength = min(distance * blurAmount, maxBlurStrength);

    vec4 blurredColor = vec4(0.0);
    float totalWeight = 0.0;

    for (int i = 0; i < 10; i++)
    {
        float weight = float(i) / float(10 - 1);
        vec2 offset = direction.xy * (blurStrength * weight);

        blurredColor += texture(tex, uv + offset) * weight;
        totalWeight += weight;
    }

    blurredColor /= totalWeight;
    color.rgb = mix(currentColor.rgb, blurredColor.rgb, blurAmount);
}