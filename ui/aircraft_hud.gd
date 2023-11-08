extends Control

@export var aircraft: RigidBody3D
@export var horizontal_speed_label: Label
@export var vertical_speed_label: Label
@export var needle: Control
@export var needle_degrees_per_ms: float = 25.
@export var needle_max_ms: float = 6.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var horizontal_velocity := Vector2(aircraft.linear_velocity.x, aircraft.linear_velocity.z)
	horizontal_speed_label.text = "%.0fkm/h" % (3.6 * horizontal_velocity.length())
	var vertical_speed := aircraft.linear_velocity.y
	vertical_speed_label.text = "%.1fm/s" % vertical_speed
	if needle:
		var target_degrees := (
			signf(vertical_speed)
			* minf(absf(vertical_speed), needle_max_ms)
			* needle_degrees_per_ms
		)
		needle.rotation_degrees = lerpf(needle.rotation_degrees, target_degrees, 0.95 * delta)
