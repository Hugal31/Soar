extends Node
class_name WindAreaComponent


func get_wind_at_position(_position: Vector3) -> Vector3:
	return Vector3()


func on_enter_wind_area(_other: WindAreaComponent):
	pass

func on_exited_wind_area(_other: WindAreaComponent):
	pass
