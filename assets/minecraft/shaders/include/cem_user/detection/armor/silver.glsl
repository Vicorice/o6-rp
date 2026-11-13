if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 26, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 15: {
            cem_reverse=1;
            modelOffset = vec3(0,-1.2856,0.2143);
            cem=45;
            cem_bound = vec4(0, 1.30731, 0.00718, 0.68758); cem_size = 1.82614; // model bounds (generated)
            break;
        }
        case 3: {
            cem_reverse=1;
            modelOffset = vec3(-0.4286,-1.2856,0.2143);
            cem=43;
            cem_bound = vec4(0.42857, 1.42307, 0, 0.68108); cem_size = 1.85425; // model bounds (generated)
            break;
        }
        case 9: {
            cem=44;
            modelOffset = vec3(0.4286,-1.2856,0.2143);
            cem_bound = vec4(-0.42857, 1.42307, 0, 0.68108); cem_size = 1.85425; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 27, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    vec3 worldPos = (inverse(ModelViewMat) * vec4(Position, 1.0)).xyz;
    switch (faceNumber)
    {
        case 9: {
            cem=47;
            cem_reverse=1;
            modelOffset = vec3(-0.149,-0.47,0.188);
            cem_bound = vec4(0.15686, 0.47059, 0, 0.58034); cem_size = 1.67035; // model bounds (generated)
            break;
        }
        case 3: {
            cem=48;
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

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 25, 255))
{
    int amt = 2 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 3: {
            cem=46;
            cem_reverse=1;
            modelOffset = vec3(0,-2.93,0.5);
            cem_bound = vec4(0, 3.0036, 0.30247, 1.2204); cem_size = 3.05386; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}