shader_type particles;

uniform vec3 box_size = vec3(6000, 2000, 6000);
uniform sampler2D height_map: repeat_disable;
global uniform float height_map_scale;
global uniform float wind_height_falloff;

global uniform float wind_strength = 10.;
global uniform vec3 wind_direction = vec3(1, 0, 0);

const float strength_multiplier = 4.;
const float spawn_margin = 0.9;

uint __hash(uint x) {
        x = ((x >> uint(16)) ^ x) * uint(73244475);
        x = ((x >> uint(16)) ^ x) * uint(73244475);
        x = (x >> uint(16)) ^ x;
        return x;
}

float __rand_from_seed(inout uint seed) {
        int k;
        int s = int(seed);
        if (s == 0)
        s = 305420679;
        k = s / 127773;
        s = 16807 * (s - k * 127773) - 2836 * k;
        if (s < 0)
                s += 2147483647;
        seed = uint(s);
        return float(seed % uint(65536)) / 65535.0;
}

float __randf_range(inout uint seed, float from, float to) {
        return __rand_from_seed(seed) * (to - from) + from;
}

mat4 __build_rotation_mat4(vec3 axis, float angle) {
        axis = normalize(axis);
        float s = sin(angle);
        float c = cos(angle);
        float oc = 1.0 - c;
        return mat4(vec4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0), vec4(oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0), vec4(oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0), vec4(0, 0, 0, 1));
}

float atan2(float y, float x)
{
    bool s = (abs(x) > abs(y));
    return mix(PI / 2.0 - atan(x, y), atan(y, x), float(s));
}

// Return the height at given coordinates in the emittor frame.
float height_at(vec2 xy) {
	vec2 uv = vec2(0.5, 0.5) + xy / box_size.xz;
	return height_map_scale * texture(height_map, uv).r;
}

void start() {
	uint seed = __hash(NUMBER + uint(1) + RANDOM_SEED);

	// TODO Make it slightly more probable to spawn near the center?
	float x = spawn_margin * __randf_range(seed, -.5, .5) * box_size.x;
	float z = spawn_margin * __randf_range(seed, -.5, .5) * box_size.z;
	float y = __randf_range(seed, height_at(vec2(x, z)), box_size.y / 2.) - box_size.y / 2.;
	VELOCITY = wind_direction * wind_strength * strength_multiplier;

	vec3 position = vec3(x, y, z);
    if (RESTART_POSITION) {
        TRANSFORM = __build_rotation_mat4(vec3(1, 0, 0), 0.);
		TRANSFORM[3] = vec4(position, 1.);
        if (RESTART_VELOCITY) {
                VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
        }
        TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
    }

	CUSTOM = vec4(0., 0., TIME, LIFETIME);
}

void process() {
	vec3 pos = (inverse(EMISSION_TRANSFORM) * TRANSFORM)[3].xyz;
	vec3 next_pos = pos + vec3(VELOCITY.x, 0., VELOCITY.z); // Step of 1sec.
	float curr_height = height_at(pos.xz), next_height = height_at(next_pos.xz);
	vec3 new_next_pos = next_pos + vec3(0, next_height - curr_height, 0);
	vec3 new_wind_direction = normalize(new_next_pos - pos);
	float weight = 1. - clamp((pos.y - curr_height) / wind_height_falloff, 0., 1.);
	VELOCITY = mix(wind_direction, new_wind_direction, weight) * wind_strength * strength_multiplier;

	float y_angle = atan2(VELOCITY.y, VELOCITY.x);
	float z_angle = atan(length(VELOCITY.xz) / VELOCITY.y) - PI * 0.5;
	mat4 new_transform =__build_rotation_mat4(vec3(0, 1, 0), y_angle) * __build_rotation_mat4(vec3(0, 0, 1), z_angle);
	new_transform[3] = vec4(pos, 1.0);
	TRANSFORM = EMISSION_TRANSFORM * new_transform;
}

//
//void process() {
//	float start_y = CUSTOM[0];
//	vec3 position = (inverse(EMISSION_TRANSFORM) * TRANSFORM[3]).xyz;
//	float x = position.x;
//	float pos_along_x = x / lift_length;
//	float height = texture(height_texture, vec2(x / lift_length)).r;
//	float previous_height = texture(height_texture, vec2((x - VELOCITY.x * 0.1) / lift_length)).r;
//	float y_velocity = (height - previous_height) / 0.1;
//	float z_angle = atan(VELOCITY.x / y_velocity) - PI * 0.5;
//	position.y = start_y + height;
//	TRANSFORM = __build_rotation_mat4(vec3(0, 0, 1), z_angle);
//	TRANSFORM[3] = vec4(position, 1.0);
//    TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
//}
