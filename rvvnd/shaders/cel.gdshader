shader_type spatial;

uniform sampler2D albedo_tex : source_color;
uniform vec3 albedo_color : source_color = vec3(1.0);
uniform sampler2D shadow_gradient : repeat_disable, source_color, filter_linear;

uniform sampler2D shadow_overlay : source_color; 
uniform float shadow_overlay_size = 1; 
uniform float shadow_overlay_mix : hint_range(0.0, 1.0) = 0.3;

void vertex() {
}

void fragment() {
	vec4 tex_color = texture(albedo_tex, UV);
	ALBEDO = tex_color.rgb * albedo_color;
}

float samplegradient(float pos, sampler2D tex) {
	return texture(tex, vec2((pos * 0.5) + 0.5, 0.0)).r;
}

void light() {
	float attenuation = max(smoothstep(0.2, 0.25, ATTENUATION), 0.3);
	float nDotL = dot(NORMAL, LIGHT);
	nDotL = texture(shadow_gradient, vec2(((nDotL * 0.5) + 0.5) * attenuation, 0.0)).r;
	float shadowIntensity = 1.0 - nDotL;
	vec2 overlayUV = SCREEN_UV * shadow_overlay_size;
	float overlayMask = texture(shadow_overlay, overlayUV).r;
	float crosshatchShadow = shadowIntensity * overlayMask;
	float finalShadow = mix(shadowIntensity, crosshatchShadow, shadow_overlay_mix);
	float finalNDotL = 1.0 - finalShadow;
	DIFFUSE_LIGHT += vec3(finalNDotL);
}

