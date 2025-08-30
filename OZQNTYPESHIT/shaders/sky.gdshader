shader_type sky;

group_uniforms Sun;
uniform float sun_size: hint_range(0.0, 1.0, 0.001) = 0.975;
group_uniforms;

group_uniforms Sky;
uniform vec3 sky_color: source_color = vec3(0.0, 0.156, 0.17);
uniform vec3 ground_color: source_color = vec3(0.0);
uniform float ground_blend_start = 0.0;
group_uniforms;

group_uniforms Clouds;
uniform vec3 cloud_color: source_color = vec3(0.75);
uniform sampler2D cloud_noise: filter_linear_mipmap, repeat_enable;
uniform float cloud_size = 0.2;
uniform vec2 wind_dir = vec2(1.0, 0.5);
uniform float wind_speed = 0.025;
group_uniforms;

void sky() {
	vec2 sky_uv = EYEDIR.xz / sqrt(EYEDIR.y);
	vec2 cloud_uv = sky_uv + (normalize(wind_dir)*TIME * wind_speed);
	float above_horizon_mask = step(0.0, EYEDIR.y);
	
	if (AT_CUBEMAP_PASS){
		float cloud = texture(cloud_noise, sky_uv).r * above_horizon_mask * EYEDIR.y;
		COLOR = mix(sky_color, cloud_color, cloud);
	} else{
		float color_delta = smoothstep(-1.0, ground_blend_start, EYEDIR.y);
		vec3 sky = mix(ground_color, sky_color, color_delta);
		float sun = smoothstep(sun_size, 1.0, dot(LIGHT0_DIRECTION, EYEDIR));
		float cloud_mask = above_horizon_mask * smoothstep(0.0, 0.3, EYEDIR.y);
		float cloud = texture(cloud_noise, cloud_uv * cloud_size).r*cloud_mask;
		vec3 final_color = mix(mix(sky, LIGHT0_COLOR, sun), cloud_color, cloud);
		COLOR.rgb = final_color;
	}
}
