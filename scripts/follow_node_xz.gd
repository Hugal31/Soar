extends Node3D

@export var to_follow: Node3D

var delta = Vector3.ZERO


func _ready() -> void:
	delta = to_follow.global_position - global_position


func _process(_delta: float):
	global_position = Vector3(
		delta.x + to_follow.global_position.x,
		global_position.y,
		delta.z + to_follow.global_position.z
	)
