/* CEM-Shader. DartCat25
*  Vertex Setup (set in block if model is cem)
*  #moj_import <cem/vert_setup.glsl>
*/ 

vec4 modelPos = ModelViewMat * vec4(Position, 1.0);
modelPos.xy += ProjMat[3].xy / vec2(ProjMat[0][0], ProjMat[1][1]);

vec2 cornerT = corner * 2 - 1;

vec4 cem_Pos = modelPos + vec4(cornerT * 2 * cem_size, 0, 0);
if (ProjMat[3][0] == -1)
{
    // GUI (orthographic, e.g. the inventory player preview): stretch the carrier quad over the
    // whole render target so the ray-traced model is never clipped, whatever the GUI scale.
    cem_Pos = vec4(cornerT / vec2(ProjMat[0][0], ProjMat[1][1]), modelPos.z, 1);
}

modelPos.w = 1;

#ifdef TRIDENT
if (ProjMat[3][0] == -1)
{
    modelPos *= (sin(GameTime * 1000) + 1) * 1000;
}
#endif

switch (cem_vertexId % 4)
{
    case 0:
        cem_pos1 = modelPos;
        cem_uv1 = vec3(uv, 1);
        break;
    case 1:
        cem_pos2 = modelPos;
        break;
    case 2:
        cem_pos3 = modelPos;
        cem_uv2 = vec3(uv, 1);
        break;
    case 3:
        cem_pos4 = modelPos;
        break;
}

cem_Pos.z = min(cem_Pos.z, -1);
cem_glPos = cem_Pos.xyz;
//cem_Pos -= ProjMat[3] / cem_Pos.z;
mat4 proj = ProjMat;
proj[3].xy = vec2(0, 0);
gl_Position = proj * cem_Pos;

#ifdef CEM_LIGHTING
vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0));
#else
vertexColor = vec4(1.0);
#endif
#ifndef EMISSIVE
cem_lightMapColor = sample_lightmap(Sampler2, UV2);
#else
cem_lightMapColor = vec4(1);
#endif
// glsl-armor-shaders v9
