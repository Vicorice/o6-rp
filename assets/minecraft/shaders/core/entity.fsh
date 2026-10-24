#version 330

// Only the armor pipelines (armor_cutout_no_cull, armor_decal_cutout_no_cull, armor_translucent) define both
// NO_OVERLAY and PER_FACE_LIGHTING. The ray tracer and every exported model are compiled only there: the driver
// compiles core/entity once per define set (10 of them), and compiling the models into all of them made pack
// reloads take seconds. Other entity pipelines get vanilla-equivalent code (and no gl_FragDepth write).
#if defined(NO_OVERLAY) && defined(PER_FACE_LIGHTING)
#define CEM_ENABLED
#endif

// Pipelines with NO_CARDINAL_LIGHTING (eyes, energy_swirl, ...) don't bind the Lighting block.
#if defined(PER_FACE_LIGHTING) || !defined(NO_CARDINAL_LIGHTING)
#define CEM_LIGHTING
#moj_import <minecraft:light.glsl>
#endif
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:matf.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec3 modelOffset;
flat in vec4 cem_color;

out vec4 fragColor;

#moj_import <cem/frag_funcs.glsl>

void main() {
#ifdef CEM_ENABLED
    gl_FragDepth = gl_FragCoord.z;
#endif
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT && cem == 0) {
        discard;
    }
#endif
    color *= vertexColor * ColorModulator;

#ifdef CEM_ENABLED
    if (cem != 0)
    {
        #moj_import <cem/frag_main_setup.glsl>

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
                #moj_import <cem_user/models.glsl>
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

#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= lightMapColor;
#endif
    color = color + cem_color;
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
// glsl-armor-shaders v9
