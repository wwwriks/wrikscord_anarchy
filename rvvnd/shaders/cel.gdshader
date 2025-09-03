shader_type spatial;

uniform sampler2D albedo_tex : source_color;
uniform vec3 albedo_color : source_color = vec3(1.0);
uniform sampler2D shadow_gradient : repeat_disable, source_color, filter_linear;

// Screenspace shadow overlay
uniform sampler2D shadow_overlay : source_color; 
uniform float shadow_overlay_mix : hint_range(0.0, 1.0) = 0.5; 

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
    float nDotL = dot(NORMAL, LIGHT);
    nDotL = samplegradient(nDotL,shadow_gradient);
    vec3 final = vec3(nDotL);
    DIFFUSE_LIGHT += vec3(final);
}
