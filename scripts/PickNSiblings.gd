class_name PickNSiblings
extends Node

## Chance of something to spawn at all. If 1, will always spawn something.
@export_range(0., 1., 0.1) var spawn_chance := 1.
## The minimum number of child to pick
@export var pick_min := 1
## The maximum number of child to pick
@export var pick_max := 1


func _ready():
	if spawn_chance < 1. and RandomNumberGeneratorManager.randf() > spawn_chance:
		get_parent().queue_free()
		return

	var parent_children := get_parent().get_children()
	var nodes_to_remove: Array[Node] = []
	var nodes_pick_chance_total := 0.
	for child in parent_children:
		if child is Node3D or child is Node2D:
			nodes_to_remove.append(child)
			nodes_pick_chance_total += child.get_meta("pick_chance", 1.)

	for i in range(0, RandomNumberGeneratorManager.randi_range(pick_min, pick_max)):
		var pick_n := RandomNumberGeneratorManager.randf_range(0, nodes_pick_chance_total)
		var sum := 0.
		for j in range(nodes_to_remove.size()):
			var child := nodes_to_remove[j]
			var child_pick_chance: float = child.get_meta("pick_chance", 1.)
			if sum <= pick_n and pick_n < sum + child_pick_chance:
				nodes_to_remove.remove_at(j)
				nodes_pick_chance_total -= child_pick_chance
				break
			sum += child_pick_chance

	for child in nodes_to_remove:
		child.queue_free()
