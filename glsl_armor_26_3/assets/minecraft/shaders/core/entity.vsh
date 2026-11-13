#version 450
#extension GL_ARB_separate_shader_objects : require
// glslang only declares gl_BaseVertexARB for GLSL >= 450.
#extension GL_ARB_shader_draw_parameters : enable

// Minecraft 26.3+ copy of this shader, loaded from the pack's glsl_armor_26_3 overlay (26.2 uses the one in the
// pack root). It is vanilla 26.3's entity.vsh plus the armor code. 26.3 compiles every shader with shaderc: includes
// are #include, and vertex outputs reach the fragment shader by explicit location, so every output keeps a fixed
// location that entity.fsh must repeat. Vanilla's outputs use 0-7; the armor outputs use 8-18.

// Tells the shared include files and the generated cem_user index files to use #include instead of #moj_import.
#define CEM_INCLUDE

// Armor pipelines only (see entity.fsh): detection and model setup are compiled out everywhere else.
#if defined(NO_OVERLAY) && defined(PER_FACE_LIGHTING) && !defined(OIT)
#define CEM_ENABLED
#endif

// Pipelines with NO_CARDINAL_LIGHTING (eyes, energy_swirl, ...) don't bind the Lighting block.
#if defined(PER_FACE_LIGHTING) || !defined(NO_CARDINAL_LIGHTING)
#define CEM_LIGHTING
#include <minecraft:light.glsl>
#endif
#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
layout(location = 3) in ivec2 UV1;
layout(location = 4) in ivec2 UV2;
layout(location = 5) in vec3 Normal;

#ifdef CEM_ENABLED
uniform sampler2D Sampler0;
#endif

#if !defined(NO_OVERLAY) && !defined(OIT_ALPHA_ONLY)
uniform sampler2D Sampler1;
#endif

#if !defined(EMISSIVE) && !defined(OIT_ALPHA_ONLY)
uniform sampler2D Sampler2;
#endif

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;

#ifdef PER_FACE_LIGHTING
layout(location = 2) out vec4 vertexPerFaceColorBack;
layout(location = 3) out vec4 vertexPerFaceColorFront;
#else
layout(location = 2) out vec4 vertexColor;
#endif

#ifndef EMISSIVE
layout(location = 4) out vec4 lightMapColor;
#endif

#ifndef NO_OVERLAY
layout(location = 5) out vec4 overlayColor;
#endif

layout(location = 6) out vec2 texCoord0;
#ifdef GLINT
layout(location = 7) out vec2 texCoordGlint;
#endif

#ifdef CEM_ENABLED
layout(location = 8) out vec4 cem_pos1;
layout(location = 9) out vec4 cem_pos2;
layout(location = 10) out vec4 cem_pos3;
layout(location = 11) out vec4 cem_pos4;
layout(location = 12) out vec3 cem_glPos;
layout(location = 13) out vec3 cem_uv1;
layout(location = 14) out vec3 cem_uv2;
layout(location = 15) out vec3 modelOffset;
layout(location = 16) flat out int cem;
layout(location = 17) flat out int cem_reverse;
layout(location = 18) flat out vec4 cem_color;
layout(location = 19) flat out vec4 cem_bound;
#endif

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

#ifdef PER_FACE_LIGHTING
    vec2 light = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
    vertexPerFaceColorBack = minecraft_mix_light_separate(-light, Color);
    vertexPerFaceColorFront = minecraft_mix_light_separate(light, Color);
#elif defined(NO_CARDINAL_LIGHTING)
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif

#if !defined(EMISSIVE) && !defined(OIT_ALPHA_ONLY)
    lightMapColor = sample_lightmap(Sampler2, UV2);
#endif

#if !defined(NO_OVERLAY) && !defined(OIT_ALPHA_ONLY)
    overlayColor = texelFetch(Sampler1, UV1, 0);
#endif

    texCoord0 = UV0;

#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif

#ifdef GLINT
    texCoordGlint = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif

#ifdef CEM_ENABLED
    cem_pos1 = vec4(0.0);
    cem_pos2 = vec4(0.0);
    cem_pos3 = vec4(0.0);
    cem_pos4 = vec4(0.0);
    cem_glPos = vec3(0.0);
    cem_uv1 = vec3(0.0);
    cem_uv2 = vec3(0.0);
    modelOffset = vec3(0.0);
    cem = 0;
    cem_reverse = 0;
    cem_color = vec4(0.0);
    cem_bound = vec4(0.0, 0.0, 0.0, -1.0); // no bounds: older exports

    // Vertex-only state written by detection/vert_setup code.
    int flipY = 0;
    vec4 cem_lightMapColor = vec4(1.0);

    // Entities are drawn from a shared vertex buffer with a base-vertex offset, and gl_VertexIndex includes it, so
    // make the index relative to the start of this draw. The define is set whenever the device supports draw
    // parameters (always on Vulkan).
#ifdef RENDERPEARL_INSTANCE_INDEX_INCLUDES_BASE_INSTANCE
    int cem_vertexId = gl_VertexIndex - gl_BaseVertexARB;
#else
    int cem_vertexId = gl_VertexIndex;
#endif

    const vec2[4] corners = vec2[4](vec2(0), vec2(0, 1), vec2(1, 1), vec2(1, 0));
    const vec2[4] corners2 = vec2[4](vec2(0), vec2(1, 0), vec2(1, 1), vec2(0, 1));
    vec2 corner = corners[cem_vertexId % 4];

    vec2 texSize = vec2(textureSize(Sampler0, 0));
    vec2 uv = floor(UV0 * texSize);

    float cem_size = 1;

    vec4 testColor = texelFetch(Sampler0, ivec2(63, 0), 0);
    vec2 armorUV = floor(UV0 * vec2(64, 32));

    vec4 armorTestColorIn = round(texelFetch(Sampler0, ivec2(uv - corners[(cem_vertexId + 3) % 4]), 0) * 255);
    vec4 armorTestColor = round(texelFetch(Sampler0, ivec2(armorUV - (1 - corner.yx) + vec2(0, 64)), 0) * 255);

    #include <cem_user/detection.glsl>

    if (cem != 0) //Setup CEM model
    {
        #include <cem/vert_setup.glsl>

        // The ray tracer lights the model itself; the carrier quad's own colour is a plain lit white.
        vec2 cemLight = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
        vertexPerFaceColorBack = minecraft_mix_light_separate(-cemLight, vec4(1.0));
        vertexPerFaceColorFront = minecraft_mix_light_separate(cemLight, vec4(1.0));
    }
#endif
}
// glsl-armor-shaders v13
