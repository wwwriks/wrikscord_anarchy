shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform vec3 main_color : source_color = vec3(1);
uniform float shadow_smooth_min : hint_range(0.0, 1) = 0.01;
uniform float shadow_smooth_max : hint_range(0.0, 1) = 0.03;
uniform bool use_attenuation = true;

group_uniforms Specular;
uniform bool use_specular = true;
uniform float specular_power : hint_range(1.0, 128.0) = 60.0;
uniform float specular_smooth_min : hint_range(0.0, 0.5) = 0.06;
uniform float specular_smooth_max : hint_range(0.0, 0.5) = 0.15;
group_uniforms;

group_uniforms Rim_Light;
uniform bool use_rim = true;
uniform float rim_power : hint_range(1.0, 32.0) = 12.0;
uniform float rim_smooth_min : hint_range(0.0, 0.1) = 0.01;
uniform float rim_smooth_max : hint_range(0.0, 0.1) = 0.02;
group_uniforms;

void vertex() {
}

void fragment(){
	vec4 tex_color = texture(albedo_texture, UV);
	ALBEDO = tex_color.rgb * main_color;
	ALPHA = tex_color.a;
}

void light(){
	float attenuation = use_attenuation ? ATTENUATION : 1.0;
	attenuation = smoothstep(shadow_smooth_min, shadow_smooth_max, attenuation);
	float nDotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	nDotL = smoothstep(shadow_smooth_min, shadow_smooth_max, nDotL);
	
	float specular = 0.0;
	if (use_specular) {
		vec3 addedCam = normalize(VIEW + LIGHT); 
		specular = clamp(dot(NORMAL, addedCam), 0.0, 1.0);
		specular = pow(specular, specular_power);
		specular = smoothstep(specular_smooth_min, specular_smooth_max, specular);
	}
	
	float rimLight = 0.0;
	if (use_rim) {
		rimLight = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
		rimLight = pow(1.0 - rimLight, rim_power) * nDotL * max(attenuation, 0.2);
		rimLight = smoothstep(rim_smooth_min, rim_smooth_max, rimLight) * 0.5;
	}
	
	vec3 diffuse_result = vec3(nDotL) * attenuation + vec3(rimLight);
	vec3 specular_result = vec3(specular) + vec3(rimLight);
	
	DIFFUSE_LIGHT += diffuse_result;
	SPECULAR_LIGHT += specular_result;
}