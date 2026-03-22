// NOTE: Shader automatically converted from StandardMaterial3D and then modified by D (me)

shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx; // cull disabled

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float distance_fade_min : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_max : hint_range(0.0, 4096.0, 0.01);
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);

uniform sampler2D texture_refraction : filter_linear_mipmap, repeat_enable;
uniform float refraction : hint_range(-1.0, 1.0, 0.001);
uniform vec4 refraction_texture_channel;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform float rim : hint_range(0.0, 1.0, 0.01);
uniform float rim_tint : hint_range(0.0, 1.0, 0.01);
uniform sampler2D texture_rim : hint_default_white, filter_linear_mipmap, repeat_enable;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform float warp_uv_scale : hint_range(0.01, 10.0) = 1.0;

// get all squiggly wiggly
vec4 warp_uvs(float _time, vec2 _uvs, float _uv_scale) {
	vec2 scroll = normalize(vec2(0.75, 0.5)) * _time * 0.1;;
	vec2 uv = (_uvs * _uv_scale) + scroll;
	vec2 waped_uv = vec2((uv.x * 5.0) + 0.5 * cos(_time + (uv.y * 2.5) * 2.125) * 0.729, 
	                     (uv.y * 5.0) + 0.5 * sin(_time + (uv.x * 2.5) * 2.317) * 0.971) * 0.2;
	
	return texture(texture_albedo, waped_uv).rgba * albedo.rgba;
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	
	vec4 warped_uvs = warp_uvs(TIME, UV, warp_uv_scale);
	ALBEDO = warped_uvs.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Emission: Enabled
	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
	// Emission Operator: Add
	EMISSION = (emission.rgb + emission_tex) * emission_energy;

	// Refraction: Enabled
	vec3 ref_normal = NORMAL;
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * dot(texture(texture_refraction, base_uv), refraction_texture_channel) * refraction;

	float ref_amount = 1.0 - albedo.a * warped_uvs.a;

	float refraction_depth_tex = textureLod(depth_texture, ref_ofs, 0.0).r;
	vec4 refraction_view_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, refraction_depth_tex, 1.0);
	refraction_view_pos.xyz /= refraction_view_pos.w;

	// If the depth buffer is lower then the model's Z position, use the refracted UV, otherwise use the normal screen UV.
	// At low depth differences, decrease refraction intensity to avoid sudden discontinuities.
	EMISSION += textureLod(screen_texture, mix(SCREEN_UV, ref_ofs, smoothstep(0.0, 1.0, VERTEX.z - refraction_view_pos.z)), ROUGHNESS * 8.0).rgb * ref_amount * EXPOSURE;
	ALBEDO *= 1.0 - ref_amount;
	// Force transparency on the material (required for refraction).
	ALPHA = 1.0;

	// Distance Fade: Pixel Alpha
	ALPHA *= clamp(smoothstep(distance_fade_min, distance_fade_max, length(VERTEX)), 0.0, 1.0);

	// Rim: Enabled
	vec2 rim_tex = texture(texture_rim, base_uv).xy;
	RIM = rim * rim_tex.x;
	RIM_TINT = rim_tint * rim_tex.y;
}
