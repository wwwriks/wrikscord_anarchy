shader_type spatial;


uniform sampler2D albedo_tex : source_color;
uniform vec3 albedo_color : source_color = vec3(1.0);

uniform sampler2D shadow_overlay; // Texture applied to shadows in screenspace
uniform float shadow_overlay_intensity : hint_range(0.0, 1.0) = 0.6; // Mix strength
uniform float shadow_overlay_scale = 5.0; // UV scale for shadow texture
uniform float shadow_smoothness_min : hint_range(0.0, 1.0) = 0.01;
uniform float shadow_smoothness_max : hint_range(0.0, 1.0) = 0.03;

uniform bool use_attenuation = true;
uniform float attenuation_smoothness_min : hint_range(0.0, 1.0) = 0.2;
uniform float attenuation_smoothness_max : hint_range(0.0, 1.0) = 0.25;

group_uniforms Specular;
uniform bool use_specular = true;
group_uniforms;

group_uniforms Rim_Light;
uniform bool use_rim = true;
uniform float rim_power : hint_range(1.0, 32.0) = 12.0;
group_uniforms;

void vertex() {
}

void fragment() {
    vec4 tex_color = texture(albedo_tex, UV);
    ALBEDO = tex_color.rgb * albedo_color;
}

void light() {
    float attenuation = use_attenuation ? smoothstep(attenuation_smoothness_min, attenuation_smoothness_max, ATTENUATION) : 1.0;

    float nDotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
    nDotL = smoothstep(shadow_smoothness_min, shadow_smoothness_max, nDotL);

    vec3 addedCam = normalize(VIEW + LIGHT);
    float vDotL = clamp(dot(NORMAL, addedCam), 0.0, 1.0);
    vDotL = pow(vDotL * attenuation, 60.0);
    vDotL = smoothstep(0.06, 0.15, vDotL);

    float rimLight = 0.0;
	if (use_rim) {
		rimLight = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    	rimLight = pow(1.0 - rimLight, rim_power) * nDotL * max(ATTENUATION, 0.2);
    	rimLight = smoothstep(0.01, 0.02, rimLight);
	}

    vec3 result = vec3(nDotL) + rimLight;

    float lit_factor = clamp(nDotL * attenuation, 0.0, 1.0);
    float base_strength = clamp((1.0 - lit_factor) * shadow_overlay_intensity, 0.0, 1.0);

    vec2 s_uv = SCREEN_UV * shadow_overlay_scale;
    float overlay_mask = texture(shadow_overlay, s_uv).r;
    float overlay_strength = base_strength * overlay_mask;

    vec3 overlay_col = texture(shadow_overlay, s_uv).rgb;
    vec3 lit_result = mix(result * attenuation, overlay_col, overlay_strength);

    DIFFUSE_LIGHT += lit_result;
    if (use_specular) {
        SPECULAR_LIGHT += vDotL;
    }
}
