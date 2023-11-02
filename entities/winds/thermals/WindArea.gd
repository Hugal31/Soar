extends Area3D
class_name WindArea


@export() var wind_component: WindAreaComponent


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_body_entered(body):
	if body is Aircraft and wind_component != null:
		var aircraft: Aircraft = body
		aircraft.on_enter_wind_area(wind_component)


func _on_body_exited(body):
	if body is Aircraft and wind_component != null:
		var aircraft: Aircraft = body
		aircraft.on_exit_wind_area(wind_component)


func _on_area_entered(area):
	if area is WindArea:
		area.on_enter_wind_area(wind_component)


# TODO I'm a bit lost on how I should do composition here.
func _on_area_exited(area):
	if area is WindArea:
		area.on_exited_wind_area(wind_component)


func on_enter_wind_area(area: WindAreaComponent):
	if self.wind_component:
		self.wind_component.on_enter_wind_area(area)


func on_exited_wind_area(area: WindAreaComponent):
	if self.wind_component:
		self.wind_component.on_exited_wind_area(area)
