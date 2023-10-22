shader_type particles;

uniform sampler2D height_texture: repeat_disable;

uniform float lift_length = 250.;
uniform float lift_width = 50.;
uniform float lift_radius = 50.;
uniform float lift_strength = 10.;

const float strength_multiplier = 4.;

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

void start() {
	uint seed = __hash(NUMBER + uint(1) + RANDOM_SEED);

	float y = __randf_range(seed, -lift_radius, lift_radius);
	float z = __randf_range(seed, -0.5 * lift_width, 0.5 * lift_width);
	float y_dist_to_core = abs(y);
	float z_dist_to_core = abs(z);
	float y_strenght = sqrt(lift_radius - y_dist_to_core) / sqrt(lift_radius);
	float z_strenght = sqrt(0.5 * lift_width - z_dist_to_core) / sqrt(0.5 * lift_width);
	float strenght = z_strenght * y_strenght;
	VELOCITY = vec3(strength_multiplier * lift_strength * strenght, 0, 0);

	float x = __randf_range(seed, 0., lift_length - VELOCITY.x * LIFETIME);

	vec3 position = vec3(x, y, z);
    if (RESTART_POSITION) {
        TRANSFORM = __build_rotation_mat4(vec3(1, 0, 0), 0.);
		TRANSFORM[3] = vec4(position, 1.);
        if (RESTART_VELOCITY) {
                VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
        }
        TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
    }
	
	CUSTOM = vec4(y, 0., TIME, LIFETIME);
}

void process() {
	float start_y = CUSTOM[0];
	vec3 position = (inverse(EMISSION_TRANSFORM) * TRANSFORM[3]).xyz;
	float x = position.x;
	float pos_along_x = x / lift_length;
	float height = texture(height_texture, vec2(x / lift_length)).r;
	float previous_height = texture(height_texture, vec2((x - VELOCITY.x * 0.1) / lift_length)).r;
	float y_velocity = (height - previous_height) / 0.1;
	float z_angle = atan(VELOCITY.x / y_velocity) - PI * 0.5;
	position.y = start_y + height;
	TRANSFORM = __build_rotation_mat4(vec3(0, 0, 1), z_angle);
	TRANSFORM[3] = vec4(position, 1.0);
    TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
}
