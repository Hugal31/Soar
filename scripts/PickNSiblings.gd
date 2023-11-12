class_name PickNSiblings
extends Node

## Chance of something to spawn at all. If 1, will always spawn something.
@export_range(0., 1., 0.1) var spawn_chance := 1.


func _ready():
	if spawn_chance < 1. and RandomNumberGeneratorManager.randf() > spawn_chance:
		get_parent().queue_free()
		return

	var parent_children := get_parent().get_children()
	var nodes_to_chose: Array[Node] = []
	var nodes_pick_chance_total := 0.
	for child in parent_children:
		if child is Node3D or child is Node2D:
			nodes_to_chose.append(child)
			nodes_pick_chance_total += child.get_meta("pick_chance", 1.)
	var pick_n := RandomNumberGeneratorManager.randf_range(0, nodes_pick_chance_total)
	var sum := 0.
	var i := 0
	Logger.info("Pick is %.1f" % pick_n)
	for child in nodes_to_chose:
		var child_pick_chance: float = child.get_meta("pick_chance", 1.)
		if sum > pick_n or pick_n > sum + child_pick_chance:
			Logger.info(
				(
					"Delete child %d %s with chance %.1f, sum is %.1f"
					% [i, child.name, child_pick_chance, sum]
				)
			)
			child.queue_free()
		sum += child_pick_chance
		i += 1
