if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 20, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 15: {
            cem_reverse=1;
            modelOffset = vec3(0,-1.2856,0.2143);
            cem=33;
            cem_bound = vec4(0.02647, 1.52993, 0.37312, 1.21814); cem_size = 2.86539; // model bounds (generated)
            break;
        }
        case 3: {
            cem_reverse=1;
            modelOffset = vec3(-0.4286,-1.2856,0.2143);
            cem=31;
            cem_bound = vec4(0.48051, 1.59206, -0.03606, 0.84132); cem_size = 2.14459; // model bounds (generated)
            break;
        }
        case 9: {
            cem=32;
            modelOffset = vec3(0.4286,-1.2856,0.2143);
            cem_bound = vec4(-0.48051, 1.59206, -0.03606, 0.84132); cem_size = 2.14459; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 21, 255))
{
    int amt = 3 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    vec3 worldPos = (inverse(ModelViewMat) * vec4(Position, 1.0)).xyz;
    switch (faceNumber)
    {
        case 9: {
            cem=35;
            cem_reverse=1;
            modelOffset = vec3(-0.149,-0.47,0.188);
            cem_bound = vec4(0.14642, 0.71561, 0, 0.84882); cem_size = 2.09894; // model bounds (generated)
            break;
        }
        case 3: {
            cem=36;
            flipY=1;
            modelOffset = vec3(0.149,-0.47,0.188);
            cem_bound = vec4(-0.14642, 0.71561, 0, 0.84882); cem_size = 2.09894; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}

if (round(texelFetch(Sampler0, ivec2(1, 0), 0) * 255) == vec4(0, 0, 19, 255))
{
    int amt = 2 * 6;
    int faceNumber = cem_vertexId / 4 % amt;
    switch (faceNumber)
    {
        case 3: {
            cem=34;
            cem_reverse=1;
            modelOffset = vec3(0,-2.93,0.5);
            cem_bound = vec4(0, 3.41489, -0.45213, 1.52723); cem_size = 3.04093; // model bounds (generated)
            break;
        }
        default: {
            gl_Position = vec4(0);
            break;
        }
    }
}