
 uniform float uVignetteDarkness = 0.3;
 uniform float uVignetteOffset = 0.5;
 void vignette(inout vec4 color, vec2 uv, float width, float height)
 {
     vec2 center = vec2(width / 2.0, height / 2.0);
     float maxDist = distance(center, vec2(0.0, 0.0));

     // Calculate the distance of the current pixel from the center
     float dist = distance(center, uv * vec2(width, height));

     // Calculate the vignette intensity based on the distance from the center
     float intensity = smoothstep(maxDist, maxDist * (1.0 - uVignetteOffset), dist);

     // Apply the vignette effect by darkening the color based on the intensity
     color.rgb *= mix(1.0 - uVignetteDarkness, 1.0, intensity);
 }