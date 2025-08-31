shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 color : source_color = vec4(0,0,0,1);
uniform float outline_size : hint_range(0.0, 100.0, 0.1) = 6.0;

void vertex() {
    vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    float pixel_world = (-view_pos.z / VIEWPORT_SIZE.y);
    float offset = outline_size * pixel_world;
    VERTEX += NORMAL * offset;
}

void fragment() {
    ALBEDO = color.rgb;
    ALPHA = color.a;
}
