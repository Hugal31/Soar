shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_lambert, vertex_lighting, blend_mix, shadows_disabled;

global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;

uniform vec3 water_albedo: source_color = vec3(0.2, 0.2, 0.8);
uniform float max_water_height: hint_range(0.0, 5.0, 0.1) = 1.;
uniform sampler2D water_level_curve: repeat_disable;

uniform vec3 sand_albedo: source_color = vec3(0.7, 0.7, 0.1);
uniform float max_sand_height: hint_range(0.0, 20.0, 0.1) = 5.;
uniform sampler2D sand_level_curve: repeat_disable;

uniform vec3 rock_albedo: source_color = vec3(0.4, 0.4, 0.4);
uniform sampler2D rock_grass_curve: repeat_disable;

uniform vec3 snow_albedo: source_color = vec3(1, 1, 1);
uniform float min_snow_height: hint_range(200.0, 1500.0, 0.1) = 500.;
uniform float max_rock_height: hint_range(200.0, 1500.0, 0.1) = 600.;
uniform sampler2D snow_level_curve: repeat_disable;

uniform vec3 grass_albedo: source_color = vec3(0.2, 0.8, 0.2);

uniform sampler2D noise_texture: filter_nearest;

//varying float height;
varying vec3 world_normal;
// https://github.com/dsoft20/psx_retroshader/blob/master/Assets/Shaders/psx-vertexlit.shader
const vec2 base_snap_res = vec2(160.0, 120.0);

uniform sampler2D heightmap: repeat_disable;

vec4 get_snapped_pos(vec4 base_pos)
{
	vec4 snapped_pos = base_pos;
	snapped_pos.xyz = base_pos.xyz / base_pos.w; // convert to normalised device coordinates (NDC)
	vec2 snap_res = floor(base_snap_res * precision_multiplier);  // increase "snappy-ness"
	snapped_pos.x = floor(snap_res.x * snapped_pos.x) / snap_res.x;  // snap the base_pos to the lower-vertex_resolution grid
	snapped_pos.y = floor(snap_res.y * snapped_pos.y) / snap_res.y;
	snapped_pos.xyz *= base_pos.w;  // convert back to projection-space
	return snapped_pos;
}

void vertex() {
	POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
	POSITION /= abs(POSITION.w);  // discard depth for affine mapping

	//height = VERTEX.y + MODEL_MATRIX[3].y;
	world_normal = NORMAL;
}

void fragment() {
	float height = texture(heightmap, UV).r;
	float noise = texture(noise_texture, UV).r;
	float scaled_noise = (noise - 0.5) * 0.2;
	float water_weight = texture(water_level_curve,
		vec2(clamp(height / max_water_height, 0., 1.))).r;
	float sand_weight = texture(sand_level_curve,
		vec2(clamp((height - max_water_height) / max_sand_height, 0., 1.))).r;
	float rock_weight = texture(rock_grass_curve,
		vec2(world_normal.y + scaled_noise)).r;
	float snow_weight = texture(snow_level_curve,
		vec2(clamp(scaled_noise + (height - min_snow_height) / (max_rock_height - min_snow_height), 0., 1.), 0.)).r;

	vec3 albedo = mix(rock_albedo, grass_albedo, rock_weight);
	albedo = mix(albedo, snow_albedo, snow_weight);
	albedo = mix(albedo, sand_albedo, 1. - sand_weight);
	albedo = mix(water_albedo, albedo, water_weight);
	ALBEDO = albedo;
}
