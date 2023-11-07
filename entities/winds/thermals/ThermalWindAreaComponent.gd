extends WindAreaComponent
class_name ThermalWindAreaComponent

@export var thermal: Thermal

@onready var parent: Node3D = get_parent()

var effective_wind_areas: Array[WindAreaComponent] = []


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


func on_enter_wind_area(other: WindAreaComponent):
	self.effective_wind_areas.push_back(other)


func on_exited_wind_area(other: WindAreaComponent):
	self.effective_wind_areas.erase(other)


func _physics_process(delta):
	if not effective_wind_areas.is_empty():
		var speed := Vector3()
		var median_position = parent.global_position
		median_position.y *= 0.5
		for wind_area in effective_wind_areas:
			speed += wind_area.get_wind_at_position(median_position)
		speed.y = 0
		parent.position += speed * delta
