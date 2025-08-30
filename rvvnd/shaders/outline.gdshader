shader_type spatial;
render_mode cull_front, unshaded, ambient_light_disabled;

uniform float outline_thickness : hint_range(0.0, 1.0, 0.001) = 0.005;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float max_distance = 50.0;

void vertex()
{
    float dist = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz);
    float scale = clamp(dist, 0.0, max_distance);
    VERTEX += NORMAL * outline_thickness * scale * (1.0 / max_distance);
}

void fragment()
{
    ALBEDO = outline_color.rgb;
}
