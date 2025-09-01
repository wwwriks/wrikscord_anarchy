shader_type sky;
render_mode use_debanding;

group_uniforms Sun;
uniform float sun_size: hint_range(0.0, 1.0, 0.001) = 0.15;
uniform float sun_blur: hint_range(0.01, 1.0, 0.011) = 0.15;
group_uniforms;

group_uniforms Sky;
uniform vec3 sky_color: source_color = vec3(0.0, 0.156, 0.17);
uniform vec3 horizon_color: source_color = vec3(0.0, 0.156, 0.17);
uniform vec3 ground_color: source_color = vec3(0.0);
uniform float exponent_factor_top : hint_range(0.0, 20.0, 0.1) = 2.0;
uniform float exponent_factor_bottom : hint_range(0.0, 20.0, 0.1) = 2.0;
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
		vec3 cubemap_sky = (sky_color + horizon_color + ground_color) / 3.0;
		COLOR = mix(cubemap_sky, cloud_color, cloud);
	} else{
		float p = EYEDIR.y;
		float p1 = 1.0 - pow(min(1.0, 1.0 - p), exponent_factor_top);
		float p3 = 1.0 - pow(min(1.0, 1.0 + p), exponent_factor_bottom);
		float p2 = 1.0 - p1 - p3;
		vec3 sky = (sky_color * p1) + (horizon_color * p2) + (ground_color * p3);

		float sun_distance = distance(LIGHT0_DIRECTION, EYEDIR);
		float sun_power = 1.0 - clamp(sun_distance/sun_size, 0.0, 1.0);
		float sun_disc = 0.0;
		if (LIGHT0_ENABLED){
			sun_disc = clamp(sun_power / sun_blur, sun_power, 1.0);
		}

		float cloud_mask = above_horizon_mask * smoothstep(0.0, 0.3, EYEDIR.y);
		float cloud = texture(cloud_noise, cloud_uv * cloud_size).r*cloud_mask;

		vec3 final_color = mix(mix(sky, LIGHT0_COLOR, sun_disc), cloud_color, cloud);
		COLOR.rgb = final_color;
	}
}
