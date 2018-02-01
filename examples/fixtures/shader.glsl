// black and white shader

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 c = Texel(texture, texture_coords); 
    return vec4(vec3(1.0, 1.0, 1.0) * (max(c.r, max(c.g, c.b))), 1.0);
}