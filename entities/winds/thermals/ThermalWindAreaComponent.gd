extends WindAreaComponent
class_name ThermalWindAreaComponent


@export var radius: float = 0


@onready var parent: Node3D = get_parent()


func get_wind_at_position(position: Vector3):
	var position_2d := parent.global_position
	position_2d.y = 0
	var body_position := position
	body_position.y = 0
	var distance_to_center := (position_2d - body_position).length()
	var power := sqrt(radius - distance_to_center)
	print("Distance: %.1f, power: %.1f" % [distance_to_center, power])
	if is_nan(power):
		return Vector3()
	return Vector3(0, power, 0)
