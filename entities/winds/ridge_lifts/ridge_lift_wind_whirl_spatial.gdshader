shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 albedo : source_color = vec4(1.0);
uniform float end_appear: hint_range(0.0, 0.5, 0.1) = 0.2;
uniform float start_dissapear: hint_range(0.5, 1.0, 0.1) = 0.8;

// Normalized progression of life, from 0 to 1.
varying flat float lifespan;

void vertex() {
	float spawn_time = INSTANCE_CUSTOM[2];
	float lifetime = INSTANCE_CUSTOM[3];
	float expiration_time = spawn_time + lifetime;	
	lifespan = 1. - ((expiration_time - TIME) / lifetime);
	
	// Y-billboard
	/*mat4 n_out2p0;
	{
		mat4 __mvm = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], MODEL_MATRIX[1], vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, MODEL_MATRIX[1].xyz)), 0.0), MODEL_MATRIX[3]);
		__mvm = __mvm * mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0 / length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		n_out2p0 = __mvm;
	}

	MODELVIEW_MATRIX = n_out2p0;*/
}

void fragment() {
	ALBEDO = albedo.rbg;
	float appear_progression = min(1., lifespan / end_appear);
	if (UV.x > appear_progression)
		discard;
	float dissapear_progression = max(0., (lifespan - start_dissapear) / (1. - start_dissapear));
	if (1. - UV.x < dissapear_progression)
		discard;
}
