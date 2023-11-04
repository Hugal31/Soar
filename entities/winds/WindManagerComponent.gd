class_name WindManagerComponent
extends Node

@export var randomize := true

@onready var horizontal_winds := _discover_horizontal_winds()


func _discover_horizontal_winds() -> Array[ProceduralRidgeLift]:
	var horizontal_winds: Array[ProceduralRidgeLift] = []
	for sibling in get_parent().get_children():
		if sibling is ProceduralRidgeLift:
			horizontal_winds.push_back(sibling)
	return horizontal_winds


func set_horizontal_wind_strength(strength: float):
	for horizontal_wind in horizontal_winds:
		horizontal_wind.ridge_lift.strength = strength
