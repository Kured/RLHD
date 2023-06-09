
#define PI 3.141592
#define iSteps 16
#define jSteps 8
#define horizonOffset 0.0

vec3 fixSeams(vec3 vec, float mipmapIndex) {
    vec3 avec = abs(vec);
    float scale = 1.0 - exp2(mipmapIndex) / 128.0;
    float M = max(max(avec.x, avec.y), avec.z);
    if (avec.x != M) vec.x *= scale;
    if (avec.y != M) vec.y *= scale;
    if (avec.z != M) vec.z *= scale;
    return vec;
}

vec3 fixSeams(vec3 vec) {
    vec3 avec = abs(vec);
    float scale = 1.0 - 1.0 / 128.0;
    float M = max(max(avec.x, avec.y), avec.z);
    if (avec.x != M) vec.x *= scale;
    if (avec.y != M) vec.y *= scale;
    if (avec.z != M) vec.z *= scale;
    return vec;
}

vec3 fixSeamsStatic(vec3 vec, float invRecMipSize) {
    vec3 avec = abs(vec);
    float scale = invRecMipSize;
    float M = max(max(avec.x, avec.y), avec.z);
    if (avec.x != M) vec.x *= scale;
    if (avec.y != M) vec.y *= scale;
    if (avec.z != M) vec.z *= scale;
    return vec;
}

vec3 calcSeam(vec3 vec) {
    vec3 avec = abs(vec);
    float M = max(avec.x, max(avec.y, avec.z));
    return vec3(avec.x != M ? 1.0 : 0.0,
    avec.y != M ? 1.0 : 0.0,
    avec.z != M ? 1.0 : 0.0);
}

vec3 applySeam(vec3 vec, vec3 seam, float scale) {
    return vec * (seam * -scale + vec3(1.0));
}

vec3 applyColorTemperature(vec3 color, float temperature)
{
    vec3 warmColor = vec3(1.0, 0.0, 0.0);     // Warm color for lower temperatures
    vec3 neutralColor = vec3(1.0, 1.0, 1.0);  // Neutral color for mid-range temperatures
    vec3 coldColor = vec3(0, 0, 1.0);     // Cold color for higher temperatures

    // Adjust the warm and cold colors based on temperature
    vec3 adjustedWarmColor = mix(warmColor, neutralColor, temperature);
    vec3 adjustedColdColor = mix(neutralColor, warmColor, temperature);

    // Calculate the intensity of the color
    float intensity = max(max(color.r, color.g), color.b);

    // Interpolate between the adjusted warm and cold colors based on temperature and intensity
    vec3 adjustedColor = mix(adjustedWarmColor, adjustedColdColor, intensity);

    return color * adjustedColor;
}

vec3 applyExposure(vec3 color, float exposure)
{
    return color * pow(2.0, exposure);
}

vec4 renderCubemap(samplerCube cubeMap, vec3 fragPosition, vec3 lightDirection)
{
    float lodLevel = 0;
    float intensity = 0.8;
    float exposure = 0.56;
    float temperature = 0.5;

    vec4 color = vec4(textureLod(cubeMap, fragPosition, lodLevel).rgb, 1.0);

    // Apply sunset effect
    float sunsetIntensity = pow(max(0.0, 1.0 - fragPosition.y), intensity);  // Intensity based on the vertical position

    // Bias the color towards warmer tones
    vec3 warmBias = vec3(1.0, 0.7, 0.5);
    vec3 sunsetColor = mix(color.rgb, warmBias, sunsetIntensity);

    // Adjust the exposure and temperature
    sunsetColor *= pow(2.0, exposure);
    sunsetColor *= vec3(temperature, 1.0, 1.0);

    return vec4(color.rgb, 1.0);
}

//
//    color.rgb = applyExposure(color.rgb, exposure);
//    color.rgb = applyColorTemperature(color.rgb, temperature);
//    // Convert color from gamma space to linear space
//    vec3 linearColor = pow(color.rgb, vec3(2.2));
//
//    // Apply intensity in linear space
//    linearColor *= intensity;
//
//    // Convert color back from linear space to gamma space
//    vec3 finalColor = pow(linearColor, vec3(1.0 / 2.2));


vec2 rsi(vec3 r0, vec3 rd, float sr) {
    // ray-sphere intersection that assumes
    // the sphere is centered at the origin.
    // No intersection when result.x > result.y
    float a = dot(rd, rd);
    float b = 2.0 * dot(rd, r0);
    float c = dot(r0, r0) - (sr * sr);
    float d = (b*b) - 4.0*a*c;
    if (d < 0.0) return vec2(1e5,-1e5);
    return vec2(
    (-b - sqrt(d))/(2.0*a),
    (-b + sqrt(d))/(2.0*a)
    );
}

vec3 atmosphere(vec3 r, vec3 r0, vec3 pSun, float iSun, float rPlanet, float rAtmos, vec3 kRlh, float kMie, float shRlh, float shMie, float g) {
    // Normalize the sun and view directions.
    pSun = normalize(pSun);
    r = normalize(r);

    // Calculate the step size of the primary ray.
    vec2 p = rsi(r0, r, rAtmos);
    if (p.x > p.y) return vec3(0,0,0);
    p.y = min(p.y, rsi(r0, r, rPlanet).x);
    float iStepSize = (p.y - p.x) / float(iSteps);

    // Initialize the primary ray time.
    float iTime = 0.0;

    // Initialize accumulators for Rayleigh and Mie scattering.
    vec3 totalRlh = vec3(0,0,0);
    vec3 totalMie = vec3(0,0,0);

    // Initialize optical depth accumulators for the primary ray.
    float iOdRlh = 0.0;
    float iOdMie = 0.0;

    // Calculate the Rayleigh and Mie phases.
    float mu = dot(r, pSun);
    float mumu = mu * mu;
    float gg = g * g;
    float pRlh = 3.0 / (16.0 * PI) * (1.0 + mumu);
    float pMie = 3.0 / (8.0 * PI) * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

    // Sample the primary ray.
    for (int i = 0; i < iSteps; i++) {

        // Calculate the primary ray sample position.
        vec3 iPos = r0 + r * (iTime + iStepSize * 0.5);

        // Calculate the height of the sample.
        float iHeight = length(iPos) - rPlanet;

        // Calculate the optical depth of the Rayleigh and Mie scattering for this step.
        float odStepRlh = exp(-iHeight / shRlh) * iStepSize;
        float odStepMie = exp(-iHeight / shMie) * iStepSize;

        // Accumulate optical depth.
        iOdRlh += odStepRlh;
        iOdMie += odStepMie;

        // Calculate the step size of the secondary ray.
        float jStepSize = rsi(iPos, pSun, rAtmos).y / float(jSteps);

        // Initialize the secondary ray time.
        float jTime = 0.0;

        // Initialize optical depth accumulators for the secondary ray.
        float jOdRlh = 0.0;
        float jOdMie = 0.0;

        // Sample the secondary ray.
        for (int j = 0; j < jSteps; j++) {

            // Calculate the secondary ray sample position.
            vec3 jPos = iPos + pSun * (jTime + jStepSize * 0.5);

            // Calculate the height of the sample.
            float jHeight = length(jPos) - rPlanet;

            // Accumulate the optical depth.
            jOdRlh += exp(-jHeight / shRlh) * jStepSize;
            jOdMie += exp(-jHeight / shMie) * jStepSize;

            // Increment the secondary ray time.
            jTime += jStepSize;
        }

        // Calculate attenuation.
        vec3 attn = exp(-(kMie * (iOdMie + jOdMie) + kRlh * (iOdRlh + jOdRlh)));

        // Accumulate scattering.
        totalRlh += odStepRlh * attn;
        totalMie += odStepMie * attn;

        // Increment the primary ray time.
        iTime += iStepSize;

    }

    // Calculate and return the final color.
    return clamp(iSun * (pRlh * kRlh * totalRlh + pMie * kMie * totalMie), vec3(0), vec3(1));
}

vec4 renderSky(vec3 viewDir, vec3 lightDir, vec3 skyColor)
{
    float rayleigh_height = 8e3;
    float sun_intensity = 22;
    bool enable_exposure = false;

    // atmosphere
    vec3 color = atmosphere(
        normalize(viewDir),             // normalized ray direction   vPosition
        vec3(0,6372e3,0),               // ray origin
        lightDir,                       // position of the sun
        sun_intensity,                  // intensity of the sun
        6371e3,                         // radius of the planet in meters
        6471e3,                         // radius of the atmosphere in meters
        vec3(5.5e-6, 13.0e-6, 22.4e-6), // Rayleigh scattering coefficient
        21e-6,                          // Mie scattering coefficient
        rayleigh_height,                // Rayleigh scale height
        1.2e3,                          // Mie scale height
        0.758                           // Mie preferred scattering direction
    );

    // Apply exposure.
    if (enable_exposure) {
        color = 1.0 - exp(-1.0 * color);
    }

    //    color.r = pow(color.r, 1.0/2.2);
    //    color.g = pow(color.g, 1.0/2.2);
    //    color.b = pow(color.b, 1.0/2.2);

    vec3 viewDirection = normalize(viewDir);
    vec3 sunDirection = normalize(lightDir);
    vec3 up = vec3(0.0, 1, 0.0);

    // Calculate the gradient factor based on the elevation angle
    float elevation = dot(viewDirection, up);
    float gradientFactor = smoothstep(0.0, 0.1, elevation + horizonOffset); // Apply the horizon offset

    vec3 bottomColor = mix(skyColor, skyColor, gradientFactor);
    vec3 _Color = mix(color, bottomColor, 1.0 - gradientFactor);

    return vec4(_Color, 1.0);
    return vec4(_Color, 1.0);
    //FragNormal = vec3(1.0, 1.0, 0.0);
}
