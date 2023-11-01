@tool
class_name NodeRandomizer
extends Node3D


@export var scenes: Array[PackedScene]


var instantiated_node: Node

func _ready():
	if is_node_ready():
		_instantiate_node()


func _instantiate_node():
	if not scenes.is_empty():
		var rng := RandomNumberGenerator.new()
		var index := rng.randi_range(0, scenes.size() - 1)
		var scene := scenes[index]
		instantiated_node = scene.instantiate()
		add_child.call_deferred(instantiated_node)

func _delete_node():
	if instantiated_node:
		remove_child.call_deferred(instantiated_node)
		instantiated_node = null

func _notification(what):
	if not is_node_ready():
		return
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			_delete_node()
		NOTIFICATION_EDITOR_POST_SAVE:
			_instantiate_node()
