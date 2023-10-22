extends WindAreaComponent
class_name ThermalWindAreaComponent


@export var thermal: Thermal

@onready var parent: Node3D = get_parent()


func get_wind_at_position(position: Vector3) -> Vector3:
	if thermal == null:
		return Vector3()

	var position_2d := parent.global_position
	position_2d.y = 0
	var body_position := position
	body_position.y = 0
	var distance_to_center := (position_2d - body_position).length()
	var power := thermal.strength * sqrt(thermal.radius - distance_to_center) / sqrt(thermal.radius)
	if is_nan(power):
		return Vector3()
	return Vector3(0, power, 0)
