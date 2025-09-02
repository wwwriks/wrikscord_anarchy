shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1800) = 50.0;
uniform float uv_warp_strength: hint_range(0.1, 20.0, 0.1) = 8.0;
uniform float chromatic_aberration_strength : hint_range(0.0, 200.0, 0.1) = 3.0;
uniform float grate_strength: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

vec2 uv_curve(vec2 uv)
{
    uv = (uv - 0.5) * 2.0;
    
    uv.x *= 1.0 + pow(abs(uv.y) / uv_warp_strength, 2.0);
    uv.y *= 1.0 + pow(abs(uv.x) / uv_warp_strength, 2.0);
    
    uv /= 1.0f;
    
    uv = (uv/2.0) + 0.5;
    return uv;
}

void fragment()
{    
    float r = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*0.0), 0.0).r;
    float g = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*chromatic_aberration_strength), 0.0).g;
    float b = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*-chromatic_aberration_strength), 0.0).b;
    
    float s = sin(uv_curve(SCREEN_UV).y * scanline_count * PI * 2.0);
    s = (s * 0.5 + 0.5) * 0.9 + 0.1;
    vec4 scan_line = vec4(vec3(pow(s, grate_strength)), 1.0);
    
    COLOR = vec4(r, g, b, 1.0) * scan_line;
}