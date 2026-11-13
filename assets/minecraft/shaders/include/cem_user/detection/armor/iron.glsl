if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 23, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 15: {
            cem_reverse=1;
            modelOffset = vec3(0,-1.2856,0.2143);
            cem=39;
            cem_bound = vec4(0, 1.07658, 0, 0.80139); cem_size = 2.03582; // model bounds (generated)
            break;
        }
        case 3: {
            cem_reverse=1;
            modelOffset = vec3(-0.4286,-1.2856,0.2143);
            cem=37;
            cem_bound = vec4(0.42857, 1.28571, 0, 0.52852); cem_size = 1.64211; // model bounds (generated)
            break;
        }
        case 9: {
            cem=38;
            modelOffset = vec3(0.4286,-1.2856,0.2143);
            cem_bound = vec4(-0.42857, 1.28571, 0, 0.52852); cem_size = 1.64211; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 24, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    vec3 worldPos = (inverse(ModelViewMat) * vec4(Position, 1.0)).xyz;
    switch (faceNumber)
    {
        case 9: {
            cem=41;
            cem_reverse=1;
            modelOffset = vec3(-0.149,-0.47,0.188);
            cem_bound = vec4(0.15686, 0.47059, 0, 0.58034); cem_size = 1.67035; // model bounds (generated)
            break;
        }
        case 3: {
            cem=42;
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

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 22, 255))
{
    int amt = 2 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 3: {
            cem=40;
            cem_reverse=1;
            modelOffset = vec3(0,-2.93,0.5);
            cem_bound = vec4(0, 2.97872, 0, 0.82917); cem_size = 2.2897; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}