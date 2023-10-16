extends RigidBody3D
class_name Aircraft

enum FlightModel {
	Arcade,
	Realist,
}

@export_group("Flight model")
@export var fligth_model: FlightModel = FlightModel.Arcade
## Acceleration, in m/s²
@export var acceleration: float = 4

## Regular bank angle in degrees.
@export var bank_angle := 30.0
## High bank angle in degrees.
@export var high_bank_angle := 50.0
## Bank velocity in degrees/s.
@export var bank_velocity = 60.0

@export_subgroup("Arcade")
@export var slow_speed: SpeedData = SpeedData.new()
@export var normal_speed: SpeedData = SpeedData.new()
@export var fast_speed: SpeedData = SpeedData.new()

@export_subgroup("Realist")
@export var lift_surface: float = 18
@export var lift_coefficient: float = 0.0018
@export var drag_surface: float = 1
@export var drag_coefficient: float = 0.0005
@export var air_density: float = 1.293

var horizontal_speed := 0.0
var base_vertical_speed := 0.0
var wind_areas: Array[WindAreaComponent] = []
var last_velocity := Vector3()

@onready var G: float = ProjectSettings.get_setting("physics/3d/default_gravity")

signal position_changed(Vector3)
signal velocity_changed(Vector3)


func on_enter_wind_area(area: WindAreaComponent):
	wind_areas.push_back(area)

func on_exit_wind_area(area: WindAreaComponent):
	var index := wind_areas.find(area)
	if index == -1:
		push_error("Exiting invalid area ", area)
		return
	wind_areas.remove_at(index)

# Called when the node enters the scene tree for the first time.
func _ready():	
	match fligth_model:
		FlightModel.Arcade:
			gravity_scale = 0
			custom_integrator = true
			horizontal_speed = normal_speed.horizontal_speed
			base_vertical_speed = -normal_speed.vertical_speed
		FlightModel.Realist:
			pass
	Engine.time_scale = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	var target_rotation_z := 0.0
	var max_bank_angle := high_bank_angle if Input.is_action_pressed("high_bank") else bank_angle
	target_rotation_z = Input.get_axis("left", "right") * max_bank_angle
	rotation_degrees.z = clampf(target_rotation_z,
		rotation_degrees.z - delta * bank_velocity,
		rotation_degrees.z + delta * bank_velocity)

	var acceleration: Vector3 = (linear_velocity - last_velocity) / delta
	last_velocity = linear_velocity
	emit_signal("position_changed", position)
	emit_signal("velocity_changed", linear_velocity)


func _integrate_forces(state: PhysicsDirectBodyState3D):
	match fligth_model:
		FlightModel.Arcade:
			_integrate_forces_arcade(state)
		FlightModel.Realist:
			_integrate_forces_realist(state)


func _integrate_forces_arcade(state: PhysicsDirectBodyState3D):
	if Input.is_action_pressed("forward"):
		_integrate_speed_data(state, fast_speed)
	elif Input.is_action_pressed("backward"):
		_integrate_speed_data(state, slow_speed)
	else:
		_integrate_speed_data(state, normal_speed)

	var bank_angle := rotation.z
	state.angular_velocity.y = -G * tan(bank_angle) / horizontal_speed
	var vel_vector := Vector3(0, 0, horizontal_speed).rotated(Vector3.UP, rotation.y)
	vel_vector.y -= base_vertical_speed
	vel_vector += _get_wind()
	linear_velocity = vel_vector


func _integrate_speed_data(state: PhysicsDirectBodyState3D, speed: SpeedData):
	horizontal_speed = clampf(
		speed.horizontal_speed,
		horizontal_speed - acceleration * state.step,
		horizontal_speed + acceleration * state.step)

	if horizontal_speed >= normal_speed.horizontal_speed:
		var weight := (fast_speed.horizontal_speed - horizontal_speed) / (fast_speed.horizontal_speed - normal_speed.horizontal_speed)
		base_vertical_speed = lerpf(fast_speed.vertical_speed, normal_speed.vertical_speed, weight)
	else:
		var weight := (normal_speed.horizontal_speed - horizontal_speed) / (normal_speed.horizontal_speed - slow_speed.horizontal_speed)
		base_vertical_speed = lerpf(normal_speed.vertical_speed, slow_speed.vertical_speed, weight)


func _integrate_forces_realist(state):
	var velocity: float = state.linear_velocity.z
	var velocity_squared := velocity * velocity
	var drag_force := 0.5 * drag_surface * drag_coefficient * air_density * velocity_squared
	var lift_force := 0.5 * lift_surface * lift_coefficient * air_density * velocity_squared
	print("lift: %.4fm/s², drag: %.4fm/s²" % [lift_force, drag_force])
	state.linear_velocity += Vector3(0, lift_force * state.step, -drag_force * state.step)


func _get_wind() -> Vector3:
	var wind := Vector3()
	for wind_area in wind_areas:
		wind += wind_area.get_wind_at_position(global_position)
	return wind
