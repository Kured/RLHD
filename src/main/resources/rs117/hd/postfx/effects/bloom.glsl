
// TODO:
// Need another frag texture to output Unlit colors (emissive)

/*
    *  Bloom shader
    *  - Takes in a texture and outputs a bloom texture
    *  - Bloom texture is a black and white texture where white is the brightest parts of the texture
    *  - Bloom texture is then added to the original texture to create a bloom effect
*/

uniform bool horizontal = true;
uniform float uThreshold = 0.87;
uniform float uBloomSpread = 4.0;
uniform int uBloomIterations = 4;
uniform int uBloomQuality = 10;
uniform float uBloomIntensity = 1.1;

vec3 getBrightColor(sampler2D tex, sampler2D emissiveTex, vec2 uv)
{
    vec3 color = texture(tex, uv).rgb;
    float emissive = texture(emissiveTex, uv).b;
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));

    if (emissive > 0.3)
        return brightness > 0.3 ? color : vec3(0.0);

    // Apply threshold to determine bright color
    return brightness > uThreshold ? color : vec3(0.0);
}

void bloom(inout vec4 color, sampler2D tex, sampler2D emissiveTex, vec2 uv)
{
    ivec2 size = textureSize(tex, 0);

    float uv_x = uv.x * size.x;
    float uv_y = uv.y * size.y;

    vec3 sum = vec3(0.0);
    float totalWeight = 0.0;

    // Outer iterations
    for (int i = 0; i < uBloomIterations; ++i) {
        float radius = float(i + 1);

        // Sub-iterations
        for (int j = 0; j < uBloomQuality; ++j) {
            float angle = float(j) / float(uBloomQuality) * 2.0 * 3.14159;
            vec2 offset = vec2(cos(angle), sin(angle)) * uBloomSpread * radius;
            vec2 sampleUV = (vec2(uv_x, uv_y) + offset) / vec2(size.x, size.y);
            sum += getBrightColor(tex, emissiveTex, sampleUV);
            totalWeight += 1.0;
        }
    }

    // Apply bloom intensity to the color
    color.rgb += (sum / totalWeight) * uBloomIntensity;
}