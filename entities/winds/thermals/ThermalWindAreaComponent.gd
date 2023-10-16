extends WindAreaComponent
class_name ThermalWindAreaComponent


@export var radius: float = 0


@onready var parent: Node3D = get_parent()


func get_wind_at_position(position: Vector3):
	return Vector3(0, 10, 0)
