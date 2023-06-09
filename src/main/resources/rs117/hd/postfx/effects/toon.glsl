const float edgeThreshold = 0.7;  // Adjust this threshold as needed
const float outlineThickness = 6;  // Adjust this thickness as needed

//

//mat3 calcLookAtMatrix(vec3 origin, vec3 target, float roll) {
//    vec3 rr = vec3(sin(roll), cos(roll), 0.0);
//    vec3 ww = normalize(target - origin);
//    vec3 uu = normalize(cross(ww, rr));
//    vec3 vv = normalize(cross(uu, ww));
//
//    return mat3(uu, vv, ww);
//}
//
//vec3 getRay(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
//    mat3 camMat = calcLookAtMatrix(origin, target, 0.0);
//    return normalize(camMat * vec3(screenPos, lensLength));
//}
//
//vec2 squareFrame(vec2 screenSize, vec2 coord) {
//    vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
//    position.x *= screenSize.x / screenSize.y;
//    return position;
//}
//
//vec2 getDeltas(sampler2D tex, vec2 uv, vec2 pixel) {
//    vec3 pole = vec3(-1, 0, +1);
//    float dpos = 0.0;
//    float dnor = 0.0;
//
//    vec4 s0 = texture(tex, uv + pixel.xy * pole.xx); // x1, y1
//    vec4 s1 = texture(tex, uv + pixel.xy * pole.yx); // x2, y1
//    vec4 s2 = texture(tex, uv + pixel.xy * pole.zx); // x3, y1
//    vec4 s3 = texture(tex, uv + pixel.xy * pole.xy); // x1, y2
//    vec4 s4 = texture(tex, uv + pixel.xy * pole.yy); // x2, y2
//    vec4 s5 = texture(tex, uv + pixel.xy * pole.zy); // x3, y2
//    vec4 s6 = texture(tex, uv + pixel.xy * pole.xz); // x1, y3
//    vec4 s7 = texture(tex, uv + pixel.xy * pole.yz); // x2, y3
//    vec4 s8 = texture(tex, uv + pixel.xy * pole.zz); // x3, y3
//
//    dpos = (
//    abs(s1.a - s7.a) +
//    abs(s5.a - s3.a) +
//    abs(s0.a - s8.a) +
//    abs(s2.a - s6.a)
//    ) * 0.5;
//    dpos += (
//    max(0.0, 1.0 - dot(s1.rgb, s7.rgb)) +
//    max(0.0, 1.0 - dot(s5.rgb, s3.rgb)) +
//    max(0.0, 1.0 - dot(s0.rgb, s8.rgb)) +
//    max(0.0, 1.0 - dot(s2.rgb, s6.rgb))
//    );
//
//    dpos = pow(max(dpos - 0.5, 0.0), 5.0);
//
//    return vec2(dpos, dnor);
//}
//
////void toon(inout vec4 color, vec2 uv, sampler2D tex, sampler2D texNormal, sampler2D texDepth, vec2 pixel, float isTerrain, float isSky) {
//////    vec3 ro = vec3(sin(iTime * 0.2), 1.5, cos(iTime * 0.2)) * 5.;
//////    vec3 ta = vec3(0, 0, 0);
//////    vec3 rd = getRay(ro, ta, squareFrame(iResolution.xy, fragCoord.xy), 2.0);
//////    vec2 uv = fragCoord.xy / iResolution.xy;
////
////    vec4 buf = texture(texNormal, uv);
////    float t = buf.a;
////    vec3 nor = buf.rgb;
////    //vec3 pos = ro + rd * t;
////
////    vec3 col = color.rgb; //vec3(0.5, 0.8, 1);
////    vec2 deltas = getDeltas(texNormal, uv, pixel * 4);
//////    if (deltas.x - deltas.y <= 0) {
//////        //col = vec3(1.0);
//////        col += max(0.2, 0.3 + dot(nor, normalize(vec3(0, 1, 0.5))));
//////        col *= vec3(1, 0.9, 0.7);
//////    }
////    col += max(0.2, 0.3 + dot(nor, normalize(vec3(0, 1, 0.5))));
////    col *= vec3(1, 0.9, 0.7);
////
////    col.r = smoothstep(0.1, 1.0, col.r);
////    col.g = smoothstep(0.1, 1.1, col.g);
////    col.b = smoothstep(-0.1, 1.0, col.b);
////    col = pow(col, vec3(1.1));
////
////    if (isTerrain > 0.1 || isSky > 0.1)
////        color = vec4(col.rgb, 1);
////    else if (deltas.x - deltas.y > 0)
////        col = vec3(0, 0, 0); // deltas.x - deltas.y;
////
////
////    color = vec4(col.rgb, 1);
////}
////
void toon(inout vec4 color, vec2 uv, sampler2D tex, sampler2D texNormal, sampler2D texDepth, vec2 pixel, float isTerrain, float isSky, float emissive)
{
    if(isTerrain > 0.0 || isSky > 0.0 || emissive > 0.1) {
        //color.rgb = texture2D(tex, uv).rgb;
        return;
    }

    vec2 offsets[9] = vec2[](
    vec2(-1, 1), vec2(0, 1), vec2(1, 1),
    vec2(-1, 0), vec2(0, 0), vec2(1, 0),
    vec2(-1, -1), vec2(0, -1), vec2(1, -1)
    );

    float kernel[9] = float[](
    1, 2, 1,
    2, 0, 2,
    1, 2, 1
    );

    vec3 baseColor = color.rgb; //texture2D(tex, uv).rgb;
    float baseDepth = texture2D(texDepth, uv).r;

    vec3 colorGrad = vec3(0.0);
    float depthGrad = 0.0;

    for (int i = 0; i < 9; i++) {
        vec2 offsetUV = uv + offsets[i] / vec2(textureSize(tex, 0));
        vec3 sampleColor = texture2D(tex, offsetUV).rgb;
        float sampleDepth = texture2D(texDepth, offsetUV).r;

        float colorIntensity = length(sampleColor - baseColor);
        float depthIntensity = abs(sampleDepth - baseDepth);

        colorGrad += colorIntensity * kernel[i] * vec3(offsets[i], 0.0);
        depthGrad += depthIntensity * kernel[i];
    }

    float edge = length(colorGrad) + depthGrad;

    if (edge > edgeThreshold) {
        // Apply dilation by expanding the outline by outlineThickness pixels
        for (float t = 0.0; t < outlineThickness; t++) {
            for (int i = 0; i < 9; i++) {
                vec2 offsetUV = uv + (offsets[i] * t) / vec2(textureSize(tex, 0));
                vec3 sampleColor = texture2D(tex, offsetUV).rgb;
                float sampleDepth = texture2D(texDepth, offsetUV).r;

                float colorIntensity = length(sampleColor - baseColor);
                float depthIntensity = abs(sampleDepth - baseDepth);

                float tempEdge = length(colorIntensity * vec3(offsets[i], 0.0)) + depthIntensity;

                if (tempEdge > edgeThreshold) {
                    edge = tempEdge;
                    break;
                }
            }
            if (edge > edgeThreshold) {
                break;
            }
        }

        color.rgb = vec3(0.0);
    } else {
        color.rgb = baseColor;
    }
}