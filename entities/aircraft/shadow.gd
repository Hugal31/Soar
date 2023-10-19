extends Node3D

@export_flags_3d_physics var collision_mask: int = 2
@export var distance: float = 100.0
@export var margin: float = 0.1
@export var raycast_width: float = 20.0

@onready var parent: Node3D = get_parent()
@onready var original_rotation = global_rotation
@onready var shadow: Node3D = get_child(0)


func _process(_delta):
	# Negate X-Z rotations
	global_rotation = Vector3(
		original_rotation.x,
		parent.global_rotation.y,
		original_rotation.z)


func _physics_process(_delta):
	var space_state = get_world_3d().direct_space_state
	var global_pos := global_position
	var point = _raycast(space_state, global_pos, Vector3(0, -distance, 5))
	if point == null:
		shadow.position = Vector3(0, 0, -distance)
		return

	var collision_points: Array[Vector3] = []
	collision_points.push_back(point)
	point = _raycast(space_state, global_pos, Vector3(raycast_width / 2, -distance, -5))
	if point != null:
		collision_points.push_back(point)
	point = _raycast(space_state, global_pos, Vector3(-raycast_width / 2, -distance, -5))
	if point != null:
		collision_points.push_back(point)
	
	var centroid := collision_points[0]
	for i in range(1, collision_points.size()):
		centroid += collision_points[i]
	centroid /= collision_points.size()
	var local_centroid := global_transform.affine_inverse() * centroid
	shadow.position = local_centroid - Vector3(0, 0, margin)

	if collision_points.size() == 3:
		var normal := (collision_points[0] - collision_points[1]).normalized().cross((collision_points[0] - collision_points[2]).normalized())
		if normal.y < 0:
			normal = -normal
		# I don't know why it needs to be normalized, the two input are normalized
		var local_normal := global_transform.basis.inverse() * normal
		var quat := Quaternion(Vector3(0, 0, -1), local_normal).normalized()
		var rot := quat.get_euler(5)
		rot.z = 0
		shadow.rotation = rot
	else:
		shadow.rotation = Vector3()

func _raycast(space_state: PhysicsDirectSpaceState3D, origin: Vector3, ray: Vector3):
	var raycast := PhysicsRayQueryParameters3D.create(origin, origin + ray)
	var intersection := space_state.intersect_ray(raycast)
	if intersection.has("position"):
		return intersection["position"]
	return null

