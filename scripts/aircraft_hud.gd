extends Control


@export var aircraft: RigidBody3D
@export var horizontal_speed_label: Label
@export var vertical_speed_label: Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var horizontal_velocity := Vector2(aircraft.linear_velocity.x, aircraft.linear_velocity.z)
	horizontal_speed_label.text = "%.0fkm/h" % (3.6 * horizontal_velocity.length())
	vertical_speed_label.text = "%.1fm/s" % aircraft.linear_velocity.y
