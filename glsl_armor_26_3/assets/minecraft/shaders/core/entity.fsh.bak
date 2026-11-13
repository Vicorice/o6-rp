#version 330
#extension GL_ARB_separate_shader_objects : require

// Minecraft 26.3+ copy of this shader, loaded from the pack's glsl_armor_26_3 overlay (26.2 uses the one in the
// pack root). It is vanilla 26.3's entity.fsh plus the armor ray tracer. Inputs must use the same locations as the
// outputs of entity.vsh.

// Tells the shared include files and the generated cem_user index files to use #include instead of #moj_import.
#define CEM_INCLUDE

// Only the armor pipelines (armor_cutout_no_cull, armor_cutout_no_cull_glint, armor_decal_cutout_no_cull,
// armor_translucent) define both NO_OVERLAY and PER_FACE_LIGHTING. The ray tracer and every exported model are
// compiled only there: core/entity is compiled once per define set, and compiling the models into all of them made
// pack reloads take seconds. Other entity pipelines (including every OIT pass) get vanilla's code.
#if defined(NO_OVERLAY) && defined(PER_FACE_LIGHTING) && !defined(OIT)
#define CEM_ENABLED
#define CEM_LIGHTING
#endif

#ifdef GLINT
#include <minecraft:globals.glsl>
#endif
#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>
#ifdef CEM_ENABLED
#include <minecraft:light.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:matf.glsl>
#endif

uniform sampler2D Sampler0;

#ifdef DISSOLVE
uniform sampler2D DissolveMaskSampler;
#endif

#ifdef GLINT
uniform sampler2D GlintSampler;
#endif

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
layout(location = 2) in vec4 vertexPerFaceColorBack;
layout(location = 3) in vec4 vertexPerFaceColorFront;
#else
layout(location = 2) in vec4 vertexColor;
#endif

#ifndef EMISSIVE
layout(location = 4) in vec4 lightMapColor;
#endif

#ifndef NO_OVERLAY
layout(location = 5) in vec4 overlayColor;
#endif

layout(location = 6) in vec2 texCoord0;
#ifdef GLINT
layout(location = 7) in vec2 texCoordGlint;
#endif

#ifdef CEM_ENABLED
layout(location = 8) in vec4 cem_pos1;
layout(location = 9) in vec4 cem_pos2;
layout(location = 10) in vec4 cem_pos3;
layout(location = 11) in vec4 cem_pos4;
layout(location = 12) in vec3 cem_glPos;
layout(location = 13) in vec3 cem_uv1;
layout(location = 14) in vec3 cem_uv2;
layout(location = 15) in vec3 modelOffset;
layout(location = 16) flat in int cem;
layout(location = 17) flat in int cem_reverse;
layout(location = 18) flat in vec4 cem_color;
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

#ifdef CEM_ENABLED
#include <cem/frag_funcs.glsl>
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    #endif

    #ifndef EMISSIVE
    color *= lightMapColor;
    #endif

    #ifdef CEM_ENABLED
    color += cem_color;
    #endif

    #ifdef GLINT
    vec4 glintColor = GlintAlpha * texture(GlintSampler, texCoordGlint);
    // Matches BlendFuntion.GLINT
    color.rgb += glintColor.rgb * glintColor.rgb;
    #endif

    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif

    return apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
}

void main() {
#ifdef CEM_ENABLED
    gl_FragDepth = gl_FragCoord.z;
    bool isCem = cem != 0;
#else
    const bool isCem = false;
#endif
    vec4 color = texture(Sampler0, texCoord0);

    #ifdef OIT_ADDITIVE
    color.a = min(0.99, color.a);
    #endif

    #ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT && !isCem) {
        discard;
    }
    #endif

    #ifdef PER_FACE_LIGHTING
    vec4 faceVertexColor = gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack;
    #else
    vec4 faceVertexColor = vertexColor;
    #endif

    #ifdef DISSOLVE
    if (faceVertexColor.a < texture(DissolveMaskSampler, texCoord0).a) {
        discard;
    }
    // The dissolve effect entirely replaces translucency
    faceVertexColor.a = 1.0;
    #endif

    color *= faceVertexColor * ColorModulator;

#ifdef CEM_ENABLED
    if (isCem)
    {
        // frag_funcs.glsl's ADD_SQUARE macro tints with vertexColor.
        vec4 vertexColor = faceVertexColor;

        #include <cem/frag_main_setup.glsl>

        // Every exported box is traced by this one loop; the model files only supply data, as `case` lines of
        // the switch below (case = cem * 256 + box index), each filling the box's rows:
        //   r0: position.xyz          r1: half size.xyz, w = 1 if bound to the hips
        //   r2: rotation angles (rad)  r3: rotation pivot.xyz     r4: hip joint.xyz
        //   r5-r10: UV rects (x, y, w, h) of the down, up, north, east, south, west faces
        // Inlining one ray tracer per box, or reading the boxes from a big constant array, both made AMD's GL
        // compiler take tens of seconds; this form compiles in well under a second.
        // min(cem, 0) is 0 here but not a compile-time constant, so drivers keep this a loop instead of unrolling it.
        vec3 camM = vec3(-center.x, -center.y, center.z);
        vec3 rayM = vec3(dirTBN.x, dirTBN.y, -dirTBN.z);
        int maxBoxes = 256 + min(cem, 0);
        for (int j = 0; j < maxBoxes; j++)
        {
            vec4 r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10;
            bool found = true;
            switch (cem * 256 + j)
            {
                #include <cem_user/models.glsl>
                default: found = false; break;
            }
            if (!found)
                break;
            mat3 Rotation = Rotate3(r2.x, 0) * Rotate3(r2.y, 1) * Rotate3(r2.z, 2);

            // Same maths as ADD_BOX_ROTATE / ADD_BOX_HIPS: hips boxes rotate the ray about the hip joint.
            bool hips = r1.w > 0.5;
            mat3 boxRot = hips ? hipsRot : mat3(1.0);
            vec3 pivotM = -(r4.xyz + modelOffset) * modelSize;
            vec3 ro = pivotM + boxRot * (camM - pivotM) + ((r0.xyz + modelOffset) + r3.xyz) * modelSize;
            vec3 rd = boxRot * rayM;
            mat3 boxLight = (hips ? hipsLightTBN : lightTBN) * transpose(Rotation);

            color = sBox(Rotation * ro - r3.xyz * modelSize, Rotation * rd, r1.xyz * modelSize, boxLight, color, minT, r6, r5, r7, r10, r9, r8);
        }

        if (minT == MAX_DEPTH)
            discard;

        writeDepth(cem_rayOrigin + dir * minT);
    }
    else
#endif
    {
        if (round(color.a * 255) == 252)
            discard;
    }

    #ifdef GLINT
    color.a = max(color.a, GlintAlpha);
    #endif

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}
// glsl-armor-shaders v10
