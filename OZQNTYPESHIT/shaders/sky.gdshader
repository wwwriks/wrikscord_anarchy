shader_type sky;

#include "remap.gdshaderinc"

uniform vec3 sky_color: source_color = vec3(0.0, 0.156, 0.17);
uniform vec3 cloud_color: source_color = vec3(0.75);
uniform sampler2D cloud_noise: filter_linear_mipmap, repeat_enable;
uniform float cloud_size = 0.1;
uniform vec2 wind_dir = vec2(1.0, 0.0);
uniform float wind_speed = 0.1;

void sky() {
	vec2 sky_uv = EYEDIR.xz / sqrt(EYEDIR.y);
	vec2 cloud_uv = sky_uv + (normalize(wind_dir)*TIME * wind_speed);
	float above_horizon_mask = step(0.0, EYEDIR.y);
	
	if (AT_CUBEMAP_PASS){
		float cloud = texture(cloud_noise, sky_uv).r * above_horizon_mask * EYEDIR.y;
		COLOR = mix(sky_color, cloud_color, cloud);
	}
	else{
		float color_delta = smoothstep(-1.0, 0.0, EYEDIR.y);
		vec3 sky = mix(vec3(0.0), sky_color, color_delta);
		float sun = smoothstep(0.99, 1.0, dot(LIGHT0_DIRECTION, EYEDIR));
		float cloud_mask = above_horizon_mask * smoothstep(0.0, 0.3, EYEDIR.y);
		float cloud = texture(cloud_noise, cloud_uv * cloud_size).r*cloud_mask;
		vec3 final_color = mix(mix(sky, LIGHT0_COLOR, sun), cloud_color, cloud);
		COLOR.rgb = final_color;
	}
}
