if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 32, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 15: {
            cem_reverse=1;
            modelOffset = vec3(0,-1.2856,0.2143);
            cem=57;
            cem_bound = vec4(0, 1.28571, -0.013, 0.6206); cem_size = 1.7291; // model bounds (generated)
            break;
        }
        case 3: {
            cem_reverse=1;
            modelOffset = vec3(-0.4286,-1.2856,0.2143);
            cem=55;
            cem_bound = vec4(0.51245, 1.31308, 0, 0.88958); cem_size = 2.05847; // model bounds (generated)
            break;
        }
        case 9: {
            cem=56;
            modelOffset = vec3(0.4286,-1.2856,0.2143);
            cem_bound = vec4(-0.51245, 1.31308, 0, 0.88958); cem_size = 2.05847; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 33, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    vec3 worldPos = (inverse(ModelViewMat) * vec4(Position, 1.0)).xyz;
    switch (faceNumber)
    {
        case 9: {
            cem=59;
            cem_reverse=1;
            modelOffset = vec3(-0.149,-0.47,0.188);
            cem_bound = vec4(0.15686, 0.47059, 0, 0.58034); cem_size = 1.67035; // model bounds (generated)
            break;
        }
        case 3: {
            cem=60;
            flipY=1;
            modelOffset = vec3(0.149,-0.47,0.188);
            cem_bound = vec4(-0.15686, 0.47059, 0, 0.58034); cem_size = 1.67035; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 31, 255))
{
    int amt = 2 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 3: {
            cem=58;
            cem_reverse=1;
            modelOffset = vec3(0,-2.93,0.5);
            cem_bound = vec4(0.37234, 2.65957, -0.85106, 1.85749); cem_size = 3.50493; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}