shader_type particles;

uniform float radius : hint_range(0, 200);
uniform float speed : hint_range(1, 1000);
uniform float height : hint_range(0, 2000);
uniform float orbit_speed : hint_range(0, 2);


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

float __rand_from_seed_m1_p1(inout uint seed) {
	return __rand_from_seed(seed) * 2.0 - 1.0;
}

float __randf_range(inout uint seed, float from, float to) {
	return __rand_from_seed(seed) * (to - from) + from;
}

uint __hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

mat3 __build_rotation_mat3(vec3 axis, float angle) {
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	return mat3(vec3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s), vec3(oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s), vec3(oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c));
}

mat4 __build_rotation_mat4(vec3 axis, float angle) {
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	return mat4(vec4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0), vec4(oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0), vec4(oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0), vec4(0, 0, 0, 1));
}

vec2 __get_random_unit_vec2(inout uint seed) {
	return normalize(vec2(__rand_from_seed_m1_p1(seed), __rand_from_seed_m1_p1(seed)));
}

vec3 __get_random_unit_vec3(inout uint seed) {
	return normalize(vec3(__rand_from_seed_m1_p1(seed), __rand_from_seed_m1_p1(seed), __rand_from_seed_m1_p1(seed)));
}

vec2 __randv2_range(inout uint seed, vec2 from, vec2 to) {
	return vec2(__randf_range(seed, from.x, to.x), __randf_range(seed, from.y, to.y));
}

vec3 __randv3_range(inout uint seed, vec3 from, vec3 to) {
	return vec3(__randf_range(seed, from.x, to.x), __randf_range(seed, from.y, to.y), __randf_range(seed, from.z, to.z));
}

vec4 __randv4_range(inout uint seed, vec4 from, vec4 to) {
	return vec4(__randf_range(seed, from.x, to.x), __randf_range(seed, from.y, to.y), __randf_range(seed, from.z, to.z), __randf_range(seed, from.w, to.w));
}

void start() {
	uint __seed = __hash(NUMBER + uint(1) + RANDOM_SEED);

	float spawn_radius = 0.9 * radius;
	float xz_distance = __randf_range(__seed, 0.0, spawn_radius);

	float angle = __randf_range(__seed, -PI, PI);
	vec2 xz_position = vec2(cos(angle), sin(angle)) * xz_distance;
	float y = height * __randf_range(__seed, -0.5, 0.5);
	vec3 position = vec3(xz_position.x, y, xz_position.y);

	float base_vertical_speed = sqrt(radius - xz_distance) / sqrt(radius);
	float vertical_speed = speed * base_vertical_speed;
	VELOCITY = vec3(0, vertical_speed, 0);

	CUSTOM = vec4(xz_distance, angle, TIME, LIFETIME);

	if (RESTART_POSITION) {
		TRANSFORM = mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(position, 1.0));
		if (RESTART_VELOCITY) {
			VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
		}
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
	}
}

void process() {
	mat4 local_transform = inverse(EMISSION_TRANSFORM) * TRANSFORM;

	float xz_distance = CUSTOM[0];
	float origin_angle = CUSTOM[1];
	float new_angle = origin_angle + orbit_speed * TIME;
	vec4 position = local_transform[3];
	position.x = cos(new_angle) * xz_distance;
	position.z = sin(new_angle) * xz_distance;

	float radial_velocity = orbit_speed * xz_distance;
	float x_angle = atan(VELOCITY.y / radial_velocity) - PI / 2.;

	// I don't know how to make them rotate while keeping them aligned with the view matrix.
	mat4 x_rotation = __build_rotation_mat4(vec3(1, 0, 0), x_angle);
	mat4 y_rotation = __build_rotation_mat4(vec3(0, 1, 0), new_angle);
	mat4 new_local_transform = y_rotation * x_rotation;
	new_local_transform[3] = position;

	TRANSFORM = EMISSION_TRANSFORM * new_local_transform;
}
