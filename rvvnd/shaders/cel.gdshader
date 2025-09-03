shader_type spatial;

uniform sampler2D albedo_tex : source_color;
uniform vec3 albedo_color : source_color = vec3(1.0);

uniform bool use_triplanar = false;
uniform bool use_world_triplanar = true;

varying vec3 uv1_triplanar_pos;

uniform float uv1_blend_sharpness : hint_range(1.0, 150.0, 0.001) = 1;
varying vec3 uv1_power_normal;

uniform vec3 uv1_scale = vec3(1);
uniform vec3 uv1_offset;

group_uniforms Shadows;
uniform bool use_attenuation = true;
uniform sampler2D shadow_gradient : repeat_disable, source_color, filter_linear;
uniform sampler2D shadow_overlay : source_color;
uniform float shadow_overlay_size = 1.0;
uniform float shadow_overlay_mix : hint_range(0.0, 1.0) = 0.3;

group_uniforms Specular;
uniform bool use_specular = true;
uniform sampler2D specular_map : source_color;
uniform float specular_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float specular_size : hint_range(1.0, 128.0) = 32.0;
uniform float specular_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float specular_shadow_threshold : hint_range(0.0, 1.0) = 0.35;
uniform float specular_shadow_softness : hint_range(0.0, 1.0) = 0.08;

group_uniforms Rimlight;
uniform bool use_rimlight = true;
uniform float rim_intensity : hint_range(0.0, 2.0) = 1.0;
uniform float rim_power : hint_range(1.0, 32.0) = 12.0;
uniform float rim_min_attenuation : hint_range(0.0, 1.0) = 0.2;


void vertex() {
    vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;

    TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
    TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
    TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
    TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);

    BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
    BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
    BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
    BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);

    if (use_triplanar) {
        uv1_power_normal = pow(abs(normal), vec3(uv1_blend_sharpness));
        uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));

        if (use_world_triplanar) {
            uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * uv1_scale + uv1_offset;
        } else {
            uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
        }

        uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
    }
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void fragment() {
    if (use_triplanar) {
        vec4 tex_color = triplanar_texture(albedo_tex, uv1_power_normal, uv1_triplanar_pos);
        ALBEDO = tex_color.rgb * albedo_color;
    } else {
        ALBEDO = texture(albedo_tex, UV).rgb * albedo_color; // Standard UV mapping
    }
}


float sample_gradient(float pos) {
	return texture(shadow_gradient, vec2(pos, 0.0)).r;
}

float crosshatch(float shadow_intensity, vec2 screen_uv) {
	vec2 uv = screen_uv * shadow_overlay_size;
	float overlay = texture(shadow_overlay, uv).r;
	return mix(shadow_intensity, shadow_intensity * overlay, shadow_overlay_mix);
}

void light() {
	float atten = use_attenuation ? ATTENUATION : 1.0;
	atten = max(smoothstep(0.2, 0.25, atten), 0.3);

	float nDotL = dot(NORMAL, LIGHT);
	nDotL = sample_gradient(nDotL * 0.5 + 0.5 * atten);
	nDotL = 1.0 - crosshatch(1.0 - nDotL, SCREEN_UV);

	float rimLight = 0.0;
	if (use_rimlight) {
		float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
		rim *= nDotL * max(ATTENUATION, rim_min_attenuation);
		rimLight = smoothstep(0.01, 0.02, rim) * rim_intensity;
	}

	float spec = 0.0;
	if (use_specular) {
		vec3 halfDir = normalize(LIGHT + VIEW);
		float specAngle = max(dot(NORMAL, halfDir), 0.0);
		float rawSpec = pow(specAngle, specular_size);
		float specMask = step(specular_threshold, rawSpec);

		float shadowMask = clamp(nDotL, 0.0, 1.0);
		float lower = specular_shadow_threshold - specular_shadow_softness * 0.5;
		float upper = specular_shadow_threshold + specular_shadow_softness * 0.5;
		float specShadowCut = smoothstep(clamp(lower, 0.0, 1.0), clamp(upper, 0.0, 1.0), shadowMask);

		float mapVal = texture(specular_map, UV).r;

		spec = specMask * specular_intensity * specShadowCut * mapVal;
	}

	DIFFUSE_LIGHT += vec3(nDotL) + rimLight;
	SPECULAR_LIGHT = vec3(spec);
}
