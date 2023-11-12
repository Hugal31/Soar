extends Node3D


@export var length: int = 3
@export var width: int = 3


const LOGNAME = "TiledTerrainSpawner"


func _ready():
	Logger.add_module(LOGNAME)

	var tiles = get_children()

	if tiles.is_empty():
		push_warning("No child in the terrin tiler")
		return

	for tile in tiles:
		remove_child(tile)

	var start_time := Time.get_ticks_msec()
	var rng := RandomNumberGenerator.new()
	@warning_ignore("integer_division")
	var width_side: int = (width - 1) / 2
	for x in range(-width_side, width_side + 1):
		for z in range(0, length):
			var tile = tiles[rng.randi_range(0, tiles.size() - 1)]
			var new_child: Node3D = tile.duplicate(0)
			new_child.position = Vector3(x * 6000, 0, z * 6000)
			if x != 0 or z != 0:
				new_child.rotation.y = rng.randi_range(0, 3) * PI * 0.5
			add_child(new_child)
	var end_time := Time.get_ticks_msec()
	Logger.info("Terrain spawning took %dms" % (end_time - start_time), LOGNAME)
