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
}

void fragment() {
	ALBEDO = albedo.rbg;
	float appear_progression = min(1., lifespan / end_appear);
	if (UV.y > appear_progression)
		discard;
	float dissapear_progression = max(0., (lifespan - start_dissapear) / (1. - start_dissapear));
	if (1. - UV.y < dissapear_progression)
		discard;
		//ALBEDO = vec3(dissapear_progression);
}
