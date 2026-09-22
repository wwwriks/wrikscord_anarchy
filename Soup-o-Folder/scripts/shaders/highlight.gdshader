shader_type spatial;
render_mode unshaded, depth_draw_never;

group_uniforms Highlight;
uniform vec4 shine_color : source_color = vec4(1.0);
uniform float shine_speed : hint_range(0, 25) = 1.0;
uniform float shine_width : hint_range(0, 2) = 1.0;
uniform float cycle_interval : hint_range(0, 100) = 1.0;
uniform float angle_fade : hint_range(0, 1) = 1.0;

group_uniforms HighlightDirection;
uniform float x_direction : hint_range(-1, 1) = 0.0;
uniform float y_direction : hint_range(-1, 1) = 0.0;
uniform float z_direction : hint_range(-1, 1) = 1.0;

float sawtooth(float x) {
	return 2.0 * ( (x + shine_speed * TIME) / (shine_width + cycle_interval) - floor( 0.5 + (x + shine_speed * TIME) / (shine_width + cycle_interval) ) );
}

void fragment() {
	vec3 w_vertex = ( INV_VIEW_MATRIX * vec4(VERTEX, 1.0) ).xyz;
	
	float projection = dot( w_vertex, normalize(vec3(x_direction, y_direction, z_direction)) );
	
	float frequency = ceil( sawtooth(projection) - sawtooth(projection + shine_width) );
	
	ALBEDO = shine_color.xyz;
	ALPHA = clamp( ( 1.0 - dot(NORMAL, VIEW) * angle_fade) * frequency * shine_color.a, 0.0, 1.0 );	
}
