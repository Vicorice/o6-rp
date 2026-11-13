if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 29, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 15: {
            cem_reverse=1;
            modelOffset = vec3(0,-1.2856,0.2143);
            cem=51;
            cem_bound = vec4(-0.04842, 1.21779, -0.01067, 0.76299); cem_size = 1.90631; // model bounds (generated)
            break;
        }
        case 3: {
            cem_reverse=1;
            modelOffset = vec3(-0.4286,-1.2856,0.2143);
            cem=49;
            cem_bound = vec4(0.45449, 1.48664, 0, 0.73853); cem_size = 1.96186; // model bounds (generated)
            break;
        }
        case 9: {
            cem=50;
            modelOffset = vec3(0.4286,-1.2856,0.2143);
            cem_bound = vec4(-0.45449, 1.48664, 0, 0.73853); cem_size = 1.96186; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 30, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    vec3 worldPos = (inverse(ModelViewMat) * vec4(Position, 1.0)).xyz;
    switch (faceNumber)
    {
        case 9: {
            cem=53;
            cem_reverse=1;
            modelOffset = vec3(-0.149,-0.47,0.188);
            cem_bound = vec4(0.14642, 0.71561, 0, 0.84882); cem_size = 2.09894; // model bounds (generated)
            break;
        }
        case 3: {
            cem=54;
            flipY=1;
            modelOffset = vec3(0.149,-0.47,0.188);
            cem_bound = vec4(-0.13669, 0.69468, 0, 0.85098); cem_size = 2.08362; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 28, 255))
{
    int amt = 2 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 3: {
            cem=52;
            cem_reverse=1;
            modelOffset = vec3(0,-2.93,0.5);
            cem_bound = vec4(0, 3.27145, 0.33532, 1.35299); cem_size = 3.30593; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}