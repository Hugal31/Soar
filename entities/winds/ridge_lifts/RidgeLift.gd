@tool
class_name RidgeLift
extends Resource

@export var strength: float = 20.0:
	set(s):
		strength = s
		emit_signal("changed")

@export var width: float = 100.0:
	set(w):
		width = w
		emit_signal("changed")

@export var radius: float = 100.0:
	set(r):
		radius = r
		emit_signal("changed")
