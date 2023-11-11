## Delete parent on spawn with a given probability

class_name RandomSpawn
extends Node

## Spawn probability. 1 means "always spawns", 0 means "never spawns".
@export_range(0., 1., 0.1) var spawn_probability: float = 0.5


func _ready():
	if RandomNumberGeneratorManager.randf() >= spawn_probability:
		get_parent().queue_free()
	else:
		queue_free()
