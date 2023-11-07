extends MeshInstance3D

@onready var parent: Node3D = get_parent()
@onready var initial_transform := transform
@export var parent_envergure := 20.0


func _process(_delta):
	var parent_rotation := parent.global_rotation
	var new_transform := Transform3D(Basis(Vector3.UP, parent_rotation.y), parent.global_position)
	new_transform *= initial_transform
	# Also move the box down so the winds don't dip in the decal
	new_transform = new_transform.translated(
		Vector3.DOWN * .5 * parent_envergure * absf(sin(parent_rotation.z))
	)
	global_transform = new_transform
