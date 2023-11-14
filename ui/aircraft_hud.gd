class_name AircraftHud
extends Control

@export var aircraft: RigidBody3D
@export var horizontal_speed_label: Label
@export var vertical_speed_label: Label
@export var needle: Control
@export var needle_degrees_per_ms: float = 25.
@export var speed_needle: Control
@export var speed_needle_affine_offset := -40
@export var speed_needle_affine_slope := 40.0
@export var needle_max_ms: float = 6.
@export var score_label: Label
@export var fuel_indicator: FuelIndicator


func set_score(score: int):
	score_label.text = "%d" % score


func set_fuel(fuel: int):
	fuel_indicator.set_fuel(fuel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var horizontal_velocity := Vector2(aircraft.linear_velocity.x, aircraft.linear_velocity.z)
	var horizontal_speed := horizontal_velocity.length()
	var horizontal_speed_kmh := 3.6 * horizontal_speed
	horizontal_speed_label.text = "%.0fkm/h" % horizontal_speed_kmh
	var vertical_speed := aircraft.linear_velocity.y
	vertical_speed_label.text = "%.1fm/s" % vertical_speed

	if needle:
		var target_degrees := (
			signf(vertical_speed)
			* minf(absf(vertical_speed), needle_max_ms)
			* needle_degrees_per_ms
		)
		needle.rotation_degrees = lerpf(needle.rotation_degrees, target_degrees, 0.95 * delta)

	if speed_needle:
		var target_degrees := clampf(
			(horizontal_speed_kmh + speed_needle_affine_offset) * speed_needle_affine_slope, 0., 320
		)
		speed_needle.rotation_degrees = lerpf(
			speed_needle.rotation_degrees, target_degrees, 0.95 * delta
		)
