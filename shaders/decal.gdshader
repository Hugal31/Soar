shader_type spatial;
render_mode unshaded, depth_draw_never, cull_front, depth_test_inverted;

uniform sampler2D decal : hint_default_black, filter_nearest;
#ifdef ENABLE_BRIGHTNESS
uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;
uniform bool emulate_lighting;
uniform float brightness;
#endif
uniform sampler2D depth : source_color, hint_depth_texture;
uniform vec2 offset = vec2(0, 0);
uniform vec2 scale = vec2(1, 1);

varying flat mat4 inv_model_view_matrix;

void vertex(){
	inv_model_view_matrix = inverse(MODELVIEW_MATRIX);
}

void fragment(){
	float zdepth = textureLod(depth, SCREEN_UV, 0.0).r * 2.0 - 1.0;
	vec4 pos = inv_model_view_matrix * INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, zdepth, 1.0);

	pos.xyz /= pos.w;

	bool inside = all(greaterThanEqual(pos.xyz, vec3(-1.0))) && all(lessThanEqual(pos.xyz, vec3(1.0)));

	if(inside){
		vec4 color = texture(decal, (pos.xy * -.5 -0.5) * scale + offset);
#ifdef ENABLE_BRIGHTNESS
		if(emulate_lighting){
			float lum = dot(textureLod(screen, SCREEN_UV, 0).rgb, vec3(0.2125, 0.7154, 0.0721));
			lum += brightness;
			lum = clamp(lum, 0.0, 1.0);
			ALBEDO = color.rgb * lum;
		}
		else
#endif
		{
			ALBEDO = color.rgb;
		}
		ALPHA = color.a;
	}else{
		discard;
	}
}