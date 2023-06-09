float dofAspect = 1;
float dofFocus = .6;
float dofRange = 100;
float dofMaxBlur = 2;
float dofAperture = .01;
bool dofDebug = false;
bool dofUseCustomDepth = false;


//#ifdef USE_CUSTOM_DEPTH
//float sceneZ = getScreenDepth(uv) * cameraFar;
//#endif

uniform sampler2D tex;

void dof_simple(inout vec4 color, sampler2D tex, vec2 uv, float depth, vec2 pixel, float aspect) {
    vec2 aspectCorrect = vec2(normalize(pixel));

    float _depth = clamp(depth, 0, 1);

    float factor = 0;
    if (dofUseCustomDepth)
        factor = clamp((1.0 / dofFocus - 1.0 / _depth) / dofRange * 500.0, -1.0, 1.0);
    else
        factor = _depth; // Use custom depth value directly
    

    if (!dofDebug) {
        vec2 dofblur = vec2(factor, factor) * dofAperture;
        vec2 dofblur9 = dofblur * 0.9 * dofMaxBlur;
        vec2 dofblur7 = dofblur * 0.7 * dofMaxBlur;
        vec2 dofblur4 = dofblur * 0.4 * dofMaxBlur;

        vec4 col;
        col  = color; //texture2D(tex, uv);
        col += texture2D(tex, uv + (vec2( 0.0,  0.4) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.15, 0.37) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.29, 0.29) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2(-0.37, 0.15) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.40, 0.0)  * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.37,-0.15) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.29,-0.29) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2(-0.15,-0.37) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.0, -0.4)  * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2(-0.15, 0.37) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2(-0.29, 0.29) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.37, 0.15) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2(-0.4,  0.0)  * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2(-0.37,-0.15) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2(-0.29,-0.29) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.15,-0.37) * aspectCorrect) * dofblur);
        col += texture2D(tex, uv + (vec2( 0.15, 0.37) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2(-0.37, 0.15) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2( 0.37,-0.15) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2(-0.15,-0.37) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2(-0.15, 0.37) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2( 0.37, 0.15) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2(-0.37,-0.15) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2( 0.15,-0.37) * aspectCorrect) * dofblur9);
        col += texture2D(tex, uv + (vec2( 0.29, 0.29) * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2( 0.40, 0.0)  * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2( 0.29,-0.29) * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2( 0.0, -0.4)  * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2(-0.29, 0.29) * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2(-0.4,  0.0)  * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2(-0.29,-0.29) * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2( 0.0,  0.4)  * aspectCorrect) * dofblur7);
        col += texture2D(tex, uv + (vec2( 0.29, 0.29) * aspectCorrect) * dofblur4);
        col += texture2D(tex, uv + (vec2( 0.40, 0.0)  * aspectCorrect) * dofblur4);
        col += texture2D(tex, uv + (vec2( 0.29,-0.29) * aspectCorrect) * dofblur4);
        col += texture2D(tex, uv + (vec2( 0.0, -0.4)  * aspectCorrect) * dofblur4);
        col += texture2D(tex, uv + (vec2(-0.29, 0.29) * aspectCorrect) * dofblur4);
        col += texture2D(tex, uv + (vec2(-0.4,  0.0)  * aspectCorrect) * dofblur4);
        col += texture2D(tex, uv + (vec2(-0.29,-0.29) * aspectCorrect) * dofblur4);
        col += texture2D(tex, uv + (vec2( 0.0,  0.4)  * aspectCorrect) * dofblur4);

        color = col / 41.0;
    } else {
        if (factor < 0.0) {
            color = factor * -vec4(1.0, 1.0, 1.0, 1.0);
        } else {
            color = vec4(factor, factor, factor, 1.0);
        }
    }
}