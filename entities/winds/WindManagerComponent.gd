class_name WindManagerComponent
extends Node

@export var horizontal_winds_groups: Node


func _ready():
	pick_one_horizontal_wind_group()


func pick_one_horizontal_wind_group():
	var n_groups := horizontal_winds_groups.get_child_count()
	var idx := RandomNumberGeneratorManager.rng.randi_range(0, n_groups - 1)
	for i in range(0, n_groups):
		var child := horizontal_winds_groups.get_child(i)
		if i != idx:
			child.queue_free()
		else:
			child.visible = true
