shader_type canvas_item;

uniform float pixelation : hint_range(0, 0.1) = 0.01;
uniform sampler2D screen_text : hint_screen_texture, filter_linear_mipmap;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float screen_width : hint_range(1, 1920) = 320;
uniform float red_color : hint_range(1, 256) = 8.0;
uniform float green_color : hint_range(1, 256) = 8.0;
uniform float blue_color : hint_range(1, 256) = 8.0;

uniform float dither_strength : hint_range(0.0, 1.0) = 0.75;

float bayer4x4(vec2 p) {
    int x = int(mod(p.x, 4.0));
    int y = int(mod(p.y, 4.0));

    int m[16] = int[16](
         0,  8,  2, 10,
        12,  4, 14,  6,
         3, 11,  1,  9,
        15,  7, 13,  5
    );

    return (float(m[y * 4 + x]) + 0.5) / 16.0;
}


void fragment() {

    vec2 viewport_size = vec2(
        1.0 / SCREEN_PIXEL_SIZE.x,
        1.0 / SCREEN_PIXEL_SIZE.y
    );

    float aspect = viewport_size.x / viewport_size.y;

    vec2 pixel_size = vec2(
        pixelation / aspect,
        pixelation
    );

    vec2 coord = SCREEN_UV;

    // Pixelation
    coord = (floor(coord / pixel_size) + 0.5) * pixel_size;

    float edge_tolerance = 0.001;

    coord = clamp(
        coord,
        pixel_size * 0.5 + edge_tolerance,
        1.0 - pixel_size * 0.5 - edge_tolerance
    );

    vec4 color = textureLod(screen_text, coord, 0.0);

    vec2 dither_coord = floor(SCREEN_UV / pixel_size);

    float b = bayer4x4(dither_coord);

    float dither = b - 0.5;

    color.r += dither * (dither_strength / red_color);
    color.g += dither * (dither_strength / green_color);
    color.b += dither * (dither_strength / blue_color);

    color.r = floor(color.r * red_color) / red_color;
    color.g = floor(color.g * green_color) / green_color;
    color.b = floor(color.b * blue_color) / blue_color;

    vec2 uv_delta = fwidth(SCREEN_UV);

    vec2 edge_dist =
        smoothstep(
            vec2(0.0),
            uv_delta * 2.0,
            SCREEN_UV
        )
        *
        smoothstep(
            vec2(0.0),
            uv_delta * 2.0,
            vec2(1.0) - SCREEN_UV
        );

    float edge_factor = edge_dist.x * edge_dist.y;

    color.a = opacity * edge_factor;


    COLOR = color;
}
