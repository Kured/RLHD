uniform float godIntensity = 2;
uniform float godWeight = .43;
uniform float godQuality = 2;
uniform float godDecay = .024;
uniform float godExposure = .3;
uniform vec3 godColor = vec3(.835,.812,.318);


#define DITHER // Dithering toggle
#define GODQUALITY 3 // 1 = low, 2 = medium, 3 = high

#if (GODQUALITY == 2)
#define SAMPLES 64
#define DENSITY 0.97
#define WEIGHT 0.25
#else
#if (GODQUALITY == 1)
#define SAMPLES 32
#define DENSITY 0.95
#define WEIGHT 0.25
#else
#define SAMPLES 16
#define DENSITY 0.93
#define WEIGHT 0.36
#endif
#endif


float sun(vec2 uv, vec2 p, vec3 lightDir) {
    float di = distance(uv, p) * length(lightDir);
    return (di <= 0.3333 / godWeight ? sqrt(1.0 - di * 3.0 / godWeight) : 0.0);
}

void godrays_simple(inout vec4 color, vec2 uv, float depth, float aspect, vec3 lightDir, sampler2D tex) {
    // sun size and position
    vec2 coords = uv;
    coords.x *= aspect;

    vec2 sunPos = vec2(lightDir.xy * aspect);
    float light = sun(coords, sunPos, lightDir);

    // get occluders
    float occluders = min(depth, 1.0);

    float col = max((light - occluders) * godIntensity, 0.0);

    vec3 occlusion = vec3(col * lightDir.z, occluders, 0.0);

    vec2 coord = uv;
    vec2 lightPos = lightDir.xy;

    float occ = texture2D(tex, uv).x; // light
    float obj = texture2D(tex, uv).y; // objects
    float dither = rand(uv);

    vec2 dtc = (coord - lightPos) * (1.0 / float(SAMPLES) * DENSITY);
    float illumdecay = 1.0;

    for (int i = 0; i < SAMPLES; i++) {
        coord -= dtc;

        #ifdef DITHER
        float s = texture2D(tex, coord + (dtc * dither)).x;
        #else
        float s = texture2D(tex, coord).x;
        #endif

        s *= illumdecay * WEIGHT;
        occ += s;
        illumdecay *= godDecay;
    }

    float rays = occ * godExposure * godLightPosition.z;

    vec4 base = color;

    vec4 blend = (1.0 - (1.0 - base) * (1.0 - rays * vec4(godColor, 1.0)));

}
