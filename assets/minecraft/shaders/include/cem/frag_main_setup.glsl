#define VERT_A 100000

vec2 texSize = textureSize(Sampler0, 0);
vec3 Pos1 = round(cem_pos1.xyz * VERT_A / cem_pos1.w) / VERT_A;
vec3 Pos2 = round(cem_pos3.xyz * VERT_A / cem_pos3.w) / VERT_A;
vec3 Pos3 = gl_PrimitiveID % 2 == 0 ? round(cem_pos2.xyz * VERT_A / cem_pos2.w) / VERT_A : round(cem_pos4.xyz * VERT_A / cem_pos4.w) / VERT_A;

// if (ProjMat[3][0] == -1)
// {
//     Pos1 /= 0x1000;
//     Pos2 /= 0x1000;
//     Pos3 /= 0x1000;
// }

vec3 tangent = normalize(gl_PrimitiveID % 2 == 0 ? Pos3 - Pos1 : Pos2 - Pos3);
vec3 bitangent = normalize(gl_PrimitiveID % 2 == 1 ? Pos1 - Pos3 : Pos3 - Pos2);
vec3 normalT = normalize(cross(tangent, bitangent));

// GUI entity rendering scales by (s, s, -s); that mirror flips the cross product, so undo it.
if (ProjMat[3][0] == -1)
    normalT *= -1;

if (cem_reverse == 1)
{
    tangent = -tangent;
    bitangent = -bitangent;
}

mat3 TBN = mat3(tangent, bitangent, normalT);

// Lighting. sBox shades faces with vanilla's minecraft_mix_light, which needs each face normal in the space the
// light directions are defined in: the space of the entity vertex Position, before ModelViewMat. A box face normal
// comes out of the ray tracer as coordinates along (tangent, bitangent, -normal) (the model frame mirrors z, see
// ADD_BOX_ROTATE), and inverse(ModelViewMat) takes view space back to Position space.
mat3 viewToPos = inverse(mat3(ModelViewMat));
mat3 lightTBN = viewToPos * mat3(tangent, bitangent, -normalT);

// Models bound to the hips (ADD_BOX_HIPS) ride on a leg quad, but the leg swings while the body does not.
// A leg's left-right axis (tangent) never changes when it swings, and world up is known, so the swing is a
// rotation about that axis. hipsRot undoes it in the (tangent, bitangent, -normal) model frame, where an
// upright body has world up along -bitangent.
// In the world, body up is world up (+Y in Position space).
// GUI renders (the inventory player preview, which also animates the legs) draw the entity flipped, so screen up is
// -Y there (vanilla's inventory light directions point along -Y for the same reason), and the preview tilts the
// whole entity about the screen X axis to follow the mouse while turning the body about its own up axis. Body up is
// then perpendicular to both the screen X axis and the leg's left-right axis: cross(tangent, screenX). That is exact
// unless the body faces straight ahead (mouse horizontally level with the preview), where the two axes coincide and
// it falls back to screen up.
// hipsLightTBN is the matching lighting matrix: lightTBN with the same swing removed, so face shading of hips-bound
// models stays constant while the leg swings (at rest it equals lightTBN).
mat3 hipsRot = mat3(1.0);
mat3 hipsLightTBN = lightTBN;
{
    vec3 worldUp;
    if (ProjMat[3][0] == -1)
    {
        vec3 screenUp = normalize(mat3(ModelViewMat) * vec3(0.0, -1.0, 0.0));
        vec3 screenX = normalize(mat3(ModelViewMat) * vec3(1.0, 0.0, 0.0));
        vec3 bodyUp = cross(tangent, screenX);
        float turned = length(bodyUp);
        bodyUp = turned > 0.0001 ? bodyUp / turned : screenUp;
        if (dot(bodyUp, screenUp) < 0.0)
            bodyUp = -bodyUp;
        worldUp = normalize(mix(screenUp, bodyUp, smoothstep(0.01, 0.03, turned)));
    }
    else
    {
        worldUp = normalize(mat3(ModelViewMat) * vec3(0.0, 1.0, 0.0));
    }
    vec2 upYZ = vec2(dot(worldUp, bitangent), -dot(worldUp, normalT));
    float upLen = length(upYZ);
    if (upLen > 0.001)
    {
        upYZ /= upLen;
        float hipsCos = -upYZ.x;
        float hipsSin = upYZ.y;
        hipsRot = mat3(1.0, 0.0, 0.0, 0.0, hipsCos, hipsSin, 0.0, -hipsSin, hipsCos);
        hipsLightTBN = viewToPos * mat3(tangent, hipsCos * bitangent + hipsSin * normalT, hipsSin * bitangent - hipsCos * normalT);
    }
}

vec2 UV1 = round(cem_uv1.xy / cem_uv1.z);
vec2 UV2 = round(cem_uv2.xy / cem_uv2.z);

vec2 stp = min(UV1, UV2);
vec2 res = abs(UV1 - UV2);

vec3 rawCenter = (Pos1 + Pos2) / 2;
vec3 cem_rayOrigin = vec3(0);
vec3 center = rawCenter * TBN;
vec3 dir = normalize(cem_glPos);
vec3 dirTBN = normalize(cem_glPos * TBN);

if (ProjMat[3][0] == -1)
{
    // GUI (orthographic): parallel rays along -Z, starting on the near plane. 26.2 GUI renders use
    // an ortho projection with near/far -1000/1000, i.e. the near plane is at view-space z = +1000.
    cem_rayOrigin = vec3(cem_glPos.xy, 1000.0);
    center = (rawCenter - cem_rayOrigin) * TBN;
    dir = vec3(0, 0, -1);
    dirTBN = normalize(dir * TBN);
}

float modelSize = length((gl_PrimitiveID % 2 == 1 ? Pos1 : Pos2) - Pos3);

float minT = MAX_DEPTH;
color = vec4(0);
// glsl-armor-shaders v9
