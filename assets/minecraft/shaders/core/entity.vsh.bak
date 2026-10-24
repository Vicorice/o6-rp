#version 450
// glslang only declares gl_BaseVertexARB for GLSL >= 450.
#extension GL_ARB_shader_draw_parameters : enable

// Pipelines with NO_CARDINAL_LIGHTING (eyes, energy_swirl, ...) don't bind the Lighting block.
#if defined(PER_FACE_LIGHTING) || !defined(NO_CARDINAL_LIGHTING)
#define CEM_LIGHTING
#moj_import <minecraft:light.glsl>
#endif
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
#ifndef NO_OVERLAY
uniform sampler2D Sampler1;
#endif
#ifndef EMISSIVE
uniform sampler2D Sampler2;
#endif

// The Vulkan backend links fragment inputs to vertex outputs by output index, not by name.
// Keep this list free of unused outputs, and write every output at the top of main()
// in exactly this order, or the fragment shader reads the wrong varyings.
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 cem_pos1;
out vec4 cem_pos2;
out vec4 cem_pos3;
out vec4 cem_pos4;
out vec3 cem_glPos;
out vec3 cem_uv1;
out vec3 cem_uv2;
out vec3 modelOffset;
flat out int cem;
flat out int cem_reverse;
flat out vec4 cem_color;

void main() {
    sphericalVertexDistance = 0.0;
    cylindricalVertexDistance = 0.0;
    vertexColor = vec4(1.0);
    lightMapColor = vec4(1.0);
    overlayColor = vec4(0.0);
    texCoord0 = vec2(0.0);
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

    // Vertex-only state written by detection/vert_setup code.
    int flipY = 0;
    vec4 cem_lightMapColor = vec4(1.0);

    // 26.2 draws entities from a shared staged vertex buffer with a base-vertex offset,
    // so gl_VertexID must be made relative to the start of this draw.
#ifdef GL_ARB_shader_draw_parameters
    int cem_vertexId = gl_VertexID - gl_BaseVertexARB;
#else
    int cem_vertexId = gl_VertexID;
#endif

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

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


#ifdef NO_CARDINAL_LIGHTING
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif
#ifndef EMISSIVE
    lightMapColor = sample_lightmap(Sampler2, UV2);
#endif
#ifndef NO_OVERLAY
    overlayColor = texelFetch(Sampler1, UV1, 0);
#else
    overlayColor = vec4(0);
#endif

    texCoord0 = UV0;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif

    #moj_import <cem_user/detection.glsl>

    if (cem != 0) //Setup CEM model
    {
        
        #moj_import <cem/vert_setup.glsl>
    }
}
// glsl-armor-shaders v6
