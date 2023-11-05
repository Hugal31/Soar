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
@export var regular_bank_angle := 30.0
## High bank angle in degrees.
@export var high_bank_angle := 50.0
## Bank velocity in degrees/s.
@export var bank_velocity = 60.0
## Pitch velocity in degrees/s.
@export var pitch_velocity = 10.0

@export_subgroup("Arcade")
@export var brake_speed: SpeedData = SpeedData.new()
@export var slow_speed: SpeedData = SpeedData.new()
@export var normal_speed: SpeedData = SpeedData.new()
@export var fast_speed: SpeedData = SpeedData.new()
@onready var target_speed: SpeedData = normal_speed

@export_subgroup("Realist")
@export var lift_surface: float = 18
@export var lift_coefficient: float = 0.0018
@export var drag_surface: float = 1
@export var drag_coefficient: float = 0.0005
@export var air_density: float = 1.293

var horizontal_speed := 0.0
var base_vertical_speed := 0.0
var wind_speed := Vector3()
var wind_areas: Array[WindAreaComponent] = []

@onready var G: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
@onready var _controller_container: Node = $ControllerContainer

var _controller: AircraftController

enum Pitch {
	Fast,
	Normal,
	Slow,
}

## Are the air brakes open?
var _air_brake_open := false
## Target bank angle in degrees
var _target_bank := 0.
var _target_pitch := Pitch.Normal


signal position_changed(Vector3)
signal velocity_changed(Vector3)


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
	animation_player.play("Default")
	set_controller(HumanAircraftController.new(self))


func set_controller(controller: AircraftController):
	for child in _controller_container.get_children():
		child.queue_free()

	_controller = controller
	_controller_container.add_child(controller)

func on_enter_wind_area(area: WindAreaComponent):
	wind_areas.push_back(area)

func on_exit_wind_area(area: WindAreaComponent):
	var index := wind_areas.find(area)
	if index == -1:
		push_error("Exiting invalid area ", area)
		return
	wind_areas.remove_at(index)

func pull_out_air_brakes():
	if not _air_brake_open:
		animation_player.play("Brake out")
		_air_brake_open = true
	
func store_air_brakes():
	if _air_brake_open:
		animation_player.play("Brake in")
		_air_brake_open = false

## Set the target bank in degrees
func set_bank(angle: float):
	_target_bank = angle
	
func set_pitch(pitch: Pitch):
	self._target_pitch = pitch

func _physics_process(delta):
	var target_rotation_z = _target_bank
	var target_rotation_x = target_speed.pitch
	rotation_degrees.z = clampf(target_rotation_z,
		rotation_degrees.z - delta * bank_velocity,
		rotation_degrees.z + delta * bank_velocity)
	rotation_degrees.x = clampf(target_rotation_x,
		rotation_degrees.x - delta * pitch_velocity,
		rotation_degrees.x + delta * pitch_velocity)

	emit_signal("position_changed", position)
	emit_signal("velocity_changed", linear_velocity)


func _integrate_forces(state: PhysicsDirectBodyState3D):
	match fligth_model:
		FlightModel.Arcade:
			_integrate_forces_arcade(state)
		FlightModel.Realist:
			_integrate_forces_realist(state)


func _integrate_forces_arcade(state: PhysicsDirectBodyState3D):
	if _air_brake_open:
		_integrate_speed_data(state, brake_speed)
	else:
		match _target_pitch:
			Pitch.Fast:
				_integrate_speed_data(state, fast_speed)
			Pitch.Normal:
				_integrate_speed_data(state, normal_speed)
			Pitch.Slow:
				_integrate_speed_data(state, slow_speed)

	var bank_angle := rotation.z
	state.angular_velocity.y = -G * tan(bank_angle) / horizontal_speed
	var target_wind_speed := _get_wind()
	var wind_speed_diff := target_wind_speed - wind_speed
	var wind_speed_diff_norm := wind_speed_diff.length()
	if (wind_speed_diff_norm > acceleration * state.step):
		target_wind_speed = wind_speed + wind_speed_diff * acceleration * state.step / wind_speed_diff_norm
	wind_speed = target_wind_speed
	var vel_vector := Vector3(0, 0, horizontal_speed).rotated(Vector3.UP, rotation.y)
	vel_vector.y -= base_vertical_speed
	vel_vector += wind_speed
	linear_velocity = vel_vector


func _integrate_speed_data(state: PhysicsDirectBodyState3D, speed: SpeedData):
	target_speed = speed
	horizontal_speed = clampf(
		speed.horizontal_speed,
		horizontal_speed - acceleration * state.step,
		horizontal_speed + acceleration * state.step)

	if horizontal_speed >= normal_speed.horizontal_speed:
		var weight := (fast_speed.horizontal_speed - horizontal_speed) / (fast_speed.horizontal_speed - normal_speed.horizontal_speed)
		base_vertical_speed = lerpf(fast_speed.vertical_speed, normal_speed.vertical_speed, weight)
	elif speed == brake_speed:
		var weight := (normal_speed.horizontal_speed - horizontal_speed) / (normal_speed.horizontal_speed - brake_speed.horizontal_speed)
		base_vertical_speed = lerpf(normal_speed.vertical_speed, brake_speed.vertical_speed, weight)
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
