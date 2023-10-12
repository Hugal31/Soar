extends Node3D


@export var length: int = 3
@export var width: int = 3


func _ready():
	var tiles = get_children()
	
	if tiles.is_empty():
		push_warning("No child in the terrin tiler")
		return

	for tile in tiles:
		remove_child(tile)

	var rng := RandomNumberGenerator.new()
	@warning_ignore("integer_division")
	var width_side: int = (width - 1) / 2
	for x in range(-width_side, width_side + 1):
		for z in range(0, length):
			var tile = tiles[rng.randi_range(0, tiles.size() - 1)]
			print("spawn")
			var new_child: Node3D = tile.duplicate()
			print("spawned")
			new_child.position = Vector3(x * 2000, 0, z * 2000)
			if x != 0 or z != 0:
				new_child.rotation.y = rng.randi_range(0, 3) * PI * 0.5
			print("add")
			add_child(new_child)
			print("added")
