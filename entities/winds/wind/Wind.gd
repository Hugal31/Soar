@tool
class_name Wind
extends Resource

@export_range(0, 30) var strength: float = 10:
	set(s):
		strength = s
		emit_signal("changed")

@export var direction: Vector3 = Vector3(1, 0, 0):
	set(d):
		direction = d.normalized()
		emit_signal("changed")
