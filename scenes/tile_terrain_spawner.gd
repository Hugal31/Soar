extends Node3D


var tile: Node3D

func _ready():
	tile = get_child(0)
	
	for x in range(-10, 10):
		for z in range(-10, 10):
			if x == 0 and z == 0:
				continue

			var new_child: Node3D = tile.duplicate()
			new_child.position = Vector3(x * 500, 0, z * 500)
			add_child(new_child)
