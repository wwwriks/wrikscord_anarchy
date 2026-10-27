shader_type canvas_item;

uniform vec3 key_color: source_color = vec3(0.0, 1.0, 0.0);
uniform float threshold: hint_range(0.0, 1.0) = 0.4;
uniform float smoothing: hint_range(0.0, 0.5) = 0.1;
uniform float spill: hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	float dist = distance(col.rgb, key_color);
	float alpha = smoothstep(threshold, threshold + smoothing, dist);

	float green = max(col.g - max(col.r, col.b), 0.0);
	col.rgb -= vec3(0.0, green * spill, 0.0);

	COLOR = vec4(col.rgb, col.a * alpha);
}