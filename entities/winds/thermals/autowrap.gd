extends Node3D

@export var autowrap_max_x := 3000

@onready var _parent := get_parent()


func _process(_delta):
	if global_position.x > autowrap_max_x:
		_parent.global_position.x = -autowrap_max_x + 1.
	elif global_position.x < -autowrap_max_x:
		_parent.global_position.x = autowrap_max_x - 1.
