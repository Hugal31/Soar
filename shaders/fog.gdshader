shader_type spatial;
render_mode cull_disabled, unshaded, depth_draw_always;

// In clip space, change to world space?
uniform float fog_start: hint_range(0., 1., 0.0001) = 0.9995;
uniform vec3 fog_color : source_color;
uniform sampler2D depth_texture : source_color, hint_depth_texture;

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	ALBEDO = fog_color;
	float depth = texture(depth_texture, SCREEN_UV).x;
	if (depth == 1. || depth < fog_start)
	{
		ALPHA = 0.;	
	}
	else
	{
		ALPHA = (depth - fog_start) / (1. - fog_start);
	}
}
