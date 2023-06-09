uniform float uNear = 0.02; // Near plane .5
uniform float uFar = 100; // Far plane 10000


vec4 alphaBlend(vec4 src, vec4 dst) {
    return vec4(
        src.rgb + dst.rgb * (1.0f - src.a),
        src.a + dst.a * (1.0f - src.a)
    );
}

float LinearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // back to NDC
    return clamp(abs((2.0 * uNear * uFar) / (uFar + uNear - z * (uFar - uNear))), 0, 1);
}