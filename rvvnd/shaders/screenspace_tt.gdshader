shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D tiling_texture : source_color, filter_nearest;
uniform float tiling_scale = 1.0;
uniform vec2 scroll_speed = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = FRAGCOORD.xy;
    vec2 tiling_uv = uv / tiling_scale;
    tiling_uv += scroll_speed * TIME;
    vec4 texture_result = texture(tiling_texture, tiling_uv);
    ALBEDO = texture_result.rgb;
}