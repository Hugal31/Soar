extends RigidBody3D


enum FlightModel {
	Arcade,
	Realist,
}

@export_group("Flight model")
@export var fligth_model: FlightModel = FlightModel.Arcade
## Acceleration, in m/s²
@export var acceleration: float = 6

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
var wind_vertical_speed := 0.0
var last_velocity := Vector3()


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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	var target_rotation_z := 0.0
	if Input.is_action_pressed("left"):
		target_rotation_z = -30
	elif Input.is_action_pressed("right"):
		target_rotation_z = 30
	rotation_degrees.z = clampf(target_rotation_z, rotation_degrees.z - delta * 60, rotation_degrees.z + delta * 60)

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

	if Input.is_action_pressed("left"):
		state.angular_velocity.y = 1
	elif Input.is_action_pressed("right"):
		state.angular_velocity.y = -1
	else:
		state.angular_velocity.y = 0

	state.linear_velocity = Vector3(0, -base_vertical_speed + wind_vertical_speed, horizontal_speed).rotated(Vector3.UP, rotation.y)


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
