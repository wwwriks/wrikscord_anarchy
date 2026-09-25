shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled;

uniform sampler2D main_texture : source_color, filter_nearest;
/**
	How many times does [code]main_texture[/code] tile? (relative to [code]coordinate_space[/code])
*/
uniform float tiling_scale = 1.0;
/**
	Combined scroll speed and direction (relative to [code]coordinate_space[/code])
*/
uniform vec2 scroll_speed = vec2(0.0);
/**
I hate blending so this is the best you'll get
*/
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;


group_uniforms Dither;
uniform float dither_start = 5.0;
uniform float dither_end = 3.0;

/**
Pattern to use when distance fading (purely aesthetic but #whocares)
Using [code]None[/code] disables distance fade
*/
uniform int dither_pattern : hint_enum(
	"None",
	"Bayer 2x2",
	"Bayer 4x4",
	"Bayer 8x8",
	"Soft Noise"
) = 2;
group_uniforms;

/**
Discards fragments in a checkerboard pattern to mimic transparency
*/
uniform bool transparent = false;

/**
Enables simple backface culling
*/
uniform bool enable_culling = true;

/**
Where do we (yes, WE) get coordinates from?
- [b]Fragment Coordinates[/b]: Screenspace, locks texture to screen
- [b]UV[/b]: Locked to UV coordinates
- [b]Global Position[/b]: Locked to global coordinates
*/
uniform int coordinate_source : hint_enum(
	"Fragment Coordinates",
	"UV"
) = 0;

/**
Darken (or brighten) surfaces based on normal and view
Makes depth easier to tell, not necessary most of the time
*/
uniform float normal_shading_strength : hint_range(-1.0, 1.0) = 0;

//varying vec3 global_position;
//varying vec3 global_normal;

float bayer2x2(ivec2 p) {
	return float(
		(p.x & 1) + ((p.y & 1) << 1)
	) * 0.25 + 0.125;
}

float bayer4x4(ivec2 p) {
	const float table[16] = float[16](
		0.0,  8.0,  2.0, 10.0,
		12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0,
		15.0, 7.0, 13.0, 5.0
	);

	return (table[(p.x & 3) + (p.y & 3) * 4] + 0.5) * 0.0625;
}

float bayer8x8(ivec2 p) {
	const float table[64] = float[64](
		0.0, 32.0, 8.0, 40.0, 2.0, 34.0, 10.0, 42.0,
		48.0, 16.0, 56.0, 24.0, 50.0, 18.0, 58.0, 26.0,
		12.0, 44.0, 4.0, 36.0, 14.0, 46.0, 6.0, 38.0,
		60.0, 28.0, 52.0, 20.0, 62.0, 30.0, 54.0, 22.0,
		3.0, 35.0, 11.0, 43.0, 1.0, 33.0, 9.0, 41.0,
		51.0, 19.0, 59.0, 27.0, 49.0, 17.0, 57.0, 25.0,
		15.0, 47.0, 7.0, 39.0, 13.0, 45.0, 5.0, 37.0,
		63.0, 31.0, 55.0, 23.0, 61.0, 29.0, 53.0, 21.0
	);

	return (table[(p.x & 7) + (p.y & 7) * 8] + 0.5) * 0.015625;
}

float soft_noise(ivec2 p) {
	float n = fract(
		sin(
			float(p.x) * 12.9898 +
			float(p.y) * 78.233
		) * 43758.5453
	);

	return n * 0.9 + 0.05;
}

float get_threshold(ivec2 pixel) {
	if (dither_pattern == 1)
		return bayer2x2(pixel);
	if (dither_pattern == 2)
		return bayer4x4(pixel);
	if (dither_pattern == 3)
		return bayer8x8(pixel);
	if (dither_pattern == 4)
		return soft_noise(pixel);
	return 0.0; //this would be option 0: None
}

void vertex() {
	//maybe use for global sampling later
	//global_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//global_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);
}

void fragment() {
	ivec2 pixel = ivec2(FRAGCOORD.xy);

	// this feels too easy
	if (enable_culling && !FRONT_FACING) {
		discard;
	}

	if (transparent && ((pixel.x + pixel.y) & 1) == 0)
		discard;

	float fade = clamp(
		(length(VERTEX) - dither_end) /
		(dither_start - dither_end),
		0.0,
		1.0
	);

	if (fade < get_threshold(pixel))
		discard;

	vec4 result;

	if (coordinate_source == 0) {

		result = texture(
			main_texture,
			FRAGCOORD.xy / tiling_scale +
			scroll_speed * TIME
		);

	} else {

		result = texture(
			main_texture,
			UV / tiling_scale +
			scroll_speed * TIME
		);

	}

	result.rgb *= 1.0 - normal_shading_strength * (1.0 - max(0.0, dot(NORMAL, VIEW)));

	ALBEDO = result.rgb;
	ALPHA = result.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}