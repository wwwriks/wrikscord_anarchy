shader_type spatial;
render_mode blend_mix, cull_front, diffuse_burley, depth_draw_always, unshaded; // cull disabled

uniform vec4 albedo_mul : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable; //filter_nearest, filter_linear_mipmap

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform float clip_high = 0.15;
uniform float warp_uv_scale : hint_range(0.01, 10.0) = 1.0;
uniform vec2 warp_uv_scroll = vec2(0.75, 0.5);
uniform float warp_uv_scroll_speed : hint_range(-10.0, 10.0) = -0.05;

// get all squiggly wiggly
vec4 warp_uvs(float _time, vec2 _uvs, float _uv_scale) {
	vec2 scroll = normalize(warp_uv_scroll) * _time * warp_uv_scroll_speed;
	vec2 uv = (_uvs * _uv_scale) + scroll;
	vec2 waped_uv = vec2((uv.x * 5.0) + 0.25 * cos(_time + (uv.y * 2.5) * 5.0), 
						(uv.y * 5.0) + 0.25 * sin(_time + (uv.x * 2.5) * 5.0)) * 0.2;
	
	return texture(texture_albedo, waped_uv).rgba * albedo_mul.rgba;
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	
	vec4 warped_uvs = warp_uvs(TIME, UV, warp_uv_scale);
	ALBEDO = warped_uvs.rgb;
	
	float a = smoothstep(0.0, clip_high, dot(warped_uvs.rgb, vec3(0.2126, 0.7152, 0.0722)));
	
	ALBEDO *=a;
	ALPHA = a;
}



