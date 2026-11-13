/* CEM-Shader. DartCat25
*  Vertex Setup (set in block if model is cem)
*  #moj_import <cem/vert_setup.glsl>
*/ 

vec4 modelPos = ModelViewMat * vec4(Position, 1.0);
modelPos.xy += ProjMat[3].xy / vec2(ProjMat[0][0], ProjMat[1][1]);

vec2 cornerT = corner * 2 - 1;

vec4 cem_Pos = modelPos + vec4(cornerT * 2 * cem_size, 0, 0);
bool cem_fittedQuad = false;
if (ProjMat[3][0] == -1)
{
    // GUI (orthographic, e.g. the inventory player preview): stretch the carrier quad over the
    // whole render target so the ray-traced model is never clipped, whatever the GUI scale.
    cem_Pos = vec4(cornerT / vec2(ProjMat[0][0], ProjMat[1][1]), modelPos.z, 1);
}
else if (cem_bound.w >= 0.0)
{
    // Every pixel of this quad runs the ray tracer, so cover only what the model can reach. The exporter sets
    // cem_size to how far (in blocks, at player scale 1) any part of the model can be from this carrier vertex.
    // The quad sits in front of the nearest point the model can have, keeps the vertex where it is on screen and
    // grows by that reach, so every model point projects inside it. When the camera is within reach (very close
    // up) the quad covers the whole screen instead.
    float depth = -modelPos.z;
    float nearest = depth - cem_size;
    if (nearest < 0.1)
    {
        cem_Pos = vec4(cornerT / vec2(ProjMat[0][0], ProjMat[1][1]), -1.0, 1.0);
    }
    else
    {
        float lateral = cem_size * (1.0 + max(abs(modelPos.x), abs(modelPos.y)) / depth);
        cem_Pos = vec4(modelPos.xy * (nearest / depth) + cornerT * lateral, -nearest, 1.0);
    }
    cem_fittedQuad = true;
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

// Older exports have no bounds: keep their fixed 2-block quad, at least 1 block from the camera.
if (!cem_fittedQuad)
    cem_Pos.z = min(cem_Pos.z, -1);
cem_glPos = cem_Pos.xyz;
//cem_Pos -= ProjMat[3] / cem_Pos.z;
mat4 proj = ProjMat;
proj[3].xy = vec2(0, 0);
gl_Position = proj * cem_Pos;

#ifndef EMISSIVE
cem_lightMapColor = sample_lightmap(Sampler2, UV2);
#else
cem_lightMapColor = vec4(1);
#endif
// glsl-armor-shaders v13
