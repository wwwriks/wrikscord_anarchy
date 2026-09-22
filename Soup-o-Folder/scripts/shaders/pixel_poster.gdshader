shader_type canvas_item;

uniform float pixelation : hint_range(0.0, 0.1) = 0.01;
uniform sampler2D screen_text : hint_screen_texture, filter_linear;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

uniform float screen_width : hint_range(1.0, 1920.0) = 320.0;

uniform float red_color : hint_range(1.0, 256.0) = 8.0;
uniform float green_color : hint_range(1.0, 256.0) = 8.0;
uniform float blue_color : hint_range(1.0, 256.0) = 8.0;

uniform float dither_strength : hint_range(0.0, 1.0) = 0.75;


float bayer4x4(vec2 p) {
    float x = mod(p.x, 4.0);
    float y = mod(p.y, 4.0);

    if (y < 1.0) {
        if (x < 1.0) return 0.5 / 16.0;
        if (x < 2.0) return 8.5 / 16.0;
        if (x < 3.0) return 2.5 / 16.0;
        return 10.5 / 16.0;
    }

    if (y < 2.0) {
        if (x < 1.0) return 12.5 / 16.0;
        if (x < 2.0) return 4.5 / 16.0;
        if (x < 3.0) return 14.5 / 16.0;
        return 6.5 / 16.0;
    }

    if (y < 3.0) {
        if (x < 1.0) return 3.5 / 16.0;
        if (x < 2.0) return 11.5 / 16.0;
        if (x < 3.0) return 1.5 / 16.0;
        return 9.5 / 16.0;
    }

    if (x < 1.0) return 15.5 / 16.0;
    if (x < 2.0) return 7.5 / 16.0;
    if (x < 3.0) return 13.5 / 16.0;
    return 5.5 / 16.0;
}


void fragment() {

    vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;

    float aspect = viewport_size.x / viewport_size.y;

    vec2 pixel_size = vec2(
        pixelation / aspect,
        pixelation
    );

    vec2 coord = SCREEN_UV;

    coord = (floor(coord / pixel_size) + 0.5) * pixel_size;

    float edge_tolerance = 0.001;

    coord = clamp(
        coord,
        pixel_size * 0.5 + edge_tolerance,
        1.0 - pixel_size * 0.5 - edge_tolerance
    );

    vec4 color = texture(screen_text, coord);

    vec2 dither_coord = floor(SCREEN_UV / pixel_size);

    float b = bayer4x4(dither_coord);
    float dither = b - 0.5;

    color.r += dither * (dither_strength / red_color);
    color.g += dither * (dither_strength / green_color);
    color.b += dither * (dither_strength / blue_color);

    color.r = floor(color.r * red_color) / red_color;
    color.g = floor(color.g * green_color) / green_color;
    color.b = floor(color.b * blue_color) / blue_color;

    float edge_x = smoothstep(
        0.0,
        0.002,
        SCREEN_UV.x
    ) * smoothstep(
        0.0,
        0.002,
        1.0 - SCREEN_UV.x
    );

    float edge_y = smoothstep(
        0.0,
        0.002,
        SCREEN_UV.y
    ) * smoothstep(
        0.0,
        0.002,
        1.0 - SCREEN_UV.y
    );

    float edge_factor = edge_x * edge_y;

    color.a = opacity * edge_factor;

    COLOR = color;
}