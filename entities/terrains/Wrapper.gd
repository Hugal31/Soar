extends Area3D

const LOGNAME = "Wrapper"


func _ready():
	KLogger.add_module(LOGNAME)
	body_entered.connect(_on_node_entered)
	area_entered.connect(_on_node_entered)


func _on_node_entered(node: Node3D):
	KLogger.debug("Node entered: %s" % node, LOGNAME)
	var local_pos := to_local(node.global_position)
	var new_local_pos := Vector3(-local_pos.x, local_pos.y, local_pos.z)
	# Add small offset to avoid teleporting back and forth
	new_local_pos.x += 0.1 * signf(local_pos.x)
	var new_global_pos := to_global(new_local_pos)
	node.global_position = new_global_pos
